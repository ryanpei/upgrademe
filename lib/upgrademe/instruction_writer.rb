require 'upgrademe/upgrades_before_opsmgr_checker'
require 'upgrademe/other_product_upgrade_validator'

module Upgrademe
  class InstructionOrderer

    def initialize(original_cf_version, latest_cf_version, latest_opsmgr_version, original_opsmgr_version, other_tiles_original, other_tiles_final, origin_filepath, latest_filepath)
      @original_cf_version = original_cf_version
      @latest_cf_version = latest_cf_version
      @latest_opsmgr_version = latest_opsmgr_version
      @original_opsmgr_version = original_opsmgr_version
      @other_tiles_original = other_tiles_original
      @other_tiles_final = other_tiles_final
      @origin_filepath = origin_filepath
      @latest_filepath = latest_filepath
    end

    def instruct
      instruction_steps=[]

      cf_step_required = Gem::Version.new(original_cf_version) < Gem::Version.new(latest_cf_version)
      opsmgr_upgrade_required = Gem::Version.new(original_opsmgr_version) < Gem::Version.new(latest_opsmgr_version)
      opsmgr_up_to_date = Gem::Version.new(original_opsmgr_version) == Gem::Version.new(latest_opsmgr_version)
      product_upgrades_req = Upgrademe::OtherProductUpgradeValidator.new.requiredornot(other_tiles_original, other_tiles_final)
      is_product_upgrades_req = product_upgrades_req.first
      products_that_need_upgrades = product_upgrades_req.last

      if opsmgr_upgrade_required
        opsmgr_instructions = 'Upgrade your Ops Manager to version ' + latest_opsmgr_version
        cf_result = Upgrademe::UpgradesBeforeOpsmgrChecker.new.check('cf', original_cf_version, latest_cf_version, latest_filepath, origin_filepath)
        other_products_results = Hash.new

        other_product_needs_mediation = false
        products_that_need_upgrades.each do |x|
          other_products_result = Upgrademe::UpgradesBeforeOpsmgrChecker.new.check(x, other_tiles_original.fetch(x), other_tiles_final.fetch(x), latest_filepath, origin_filepath)
          other_products_results[x]=other_products_result
          if other_products_result.first
            other_product_needs_mediation = true
          end
        end

        while cf_step_required || is_product_upgrades_req

          if cf_result.first
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)
            cf_result = Upgrademe::UpgradesBeforeOpsmgrChecker.new.check('cf', cf_result.last, latest_cf_version, latest_filepath, origin_filepath)
          elsif other_product_needs_mediation
            products_that_need_upgrades.each do |x|
              if other_products_results.fetch(x).first
                instruction_steps.push('Upgrade ' + x + ' to version ' + other_products_results.fetch(x).last)
                other_products_result = Upgrademe::UpgradesBeforeOpsmgrChecker.new.check(x, other_products_results.fetch(x).last, other_tiles_final.fetch(x), latest_filepath, origin_filepath)
                other_products_results[x]=other_products_result
              end
            end
            other_product_needs_mediation = false

          else
            instruction_steps.push(opsmgr_instructions)
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)
            other_tiles_original.keys.each do |x|
              instruction_steps.push('Upgrade ' + x + ' to version ' + other_products_results.fetch(x).last)
            end
            cf_step_required = false
            is_product_upgrades_req = false
          end
        end

      elsif opsmgr_up_to_date
        if cf_step_required
          instruction_steps.push('You have the latest version of Ops Manager installed.')
          instruction_steps.push('Upgrade Elastic Runtime to version ' + latest_cf_version)
        else
          instruction_steps.push('You have the latest versions of Ops Manager and Elastic Runtime')
        end
        if is_product_upgrades_req
          products_that_need_upgrades.each do |x|
            instruction_steps.push('Upgrade ' + x + ' to version ' + other_tiles_final.fetch(x))
          end
        else
          instruction_steps.push('You have the latest of all products.')
        end
      else
        instruction = 'Something is wrong...'
        instruction_steps.push(instruction)
      end

      i = 1
      puts 'Here are your upgrade instructions. Best of luck!'.green
      instruction_steps.each do |x|
        puts (i.to_s + '. ' + x).white
        i = i+1
      end
    end

    private

    attr_reader :original_cf_version, :latest_cf_version, :latest_opsmgr_version, :original_opsmgr_version,
                :other_tiles_original, :other_tiles_final, :origin_filepath, :latest_filepath
  end
end