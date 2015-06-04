module Upgrademe
  class InstructionOrderer
    def instruct(original_cf_version,latest_cf_version,latest_opsmgr_version,original_opsmgr_version,other_tiles_original,other_tiles_final,origin_filepath,latest_filepath)
      require 'upgrademe/check_upgrades_before_opsmgr'
      require 'upgrademe/other_product_upgrade_validator'

      instruction_steps=[]

      cf_step_required = Gem::Version.new(original_cf_version) < Gem::Version.new(latest_cf_version)
      opsmgr_upgrade_required = Gem::Version.new(original_opsmgr_version) < Gem::Version.new(latest_opsmgr_version)
      opsmgr_up_to_date = Gem::Version.new(original_opsmgr_version) == Gem::Version.new(latest_opsmgr_version)
      product_upgrades_req = Upgrademe::OtherProductUpgradeValidator.new.requiredornot(other_tiles_original, other_tiles_final)

      if opsmgr_upgrade_required
        opsmgr_instructions = 'Upgrade your Ops Manager to version ' + latest_opsmgr_version
        cf_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check('cf', original_cf_version, latest_cf_version, latest_filepath, origin_filepath)
        other_products_results = Hash.new

        other_product_needs_mediation = false
        other_tiles_original.keys.each do |x|
          other_products_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check(x, other_tiles_original.fetch(x), other_tiles_final.fetch(x), latest_filepath, origin_filepath)
          other_products_results[x]=other_products_result
          if other_products_result.first
            other_product_needs_mediation = true
          end
        end

        while cf_step_required || product_upgrades_req

          if cf_result.first
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)
            cf_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check('cf', cf_result.last, latest_cf_version, latest_filepath, origin_filepath)
          elsif other_product_needs_mediation
            other_tiles_original.keys.each do |x|
              if other_products_results.fetch(x).first
                instruction_steps.push('Upgrade ' + x + ' to version ' + other_products_results.fetch(x).last)
                other_products_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check(x, other_products_results.fetch(x).last, other_tiles_final.fetch(x), latest_filepath, origin_filepath)
                other_products_results[x]=other_products_result
              end
            end
            other_product_needs_mediation = false

          else
            instruction_steps.push(opsmgr_instructions)
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)
            cf_step_required = false
            product_upgrades_req = false
          end
        end

      elsif opsmgr_up_to_date
        if Gem::Version.new(original_cf_version) == Gem::Version.new(latest_cf_version)
          instruction_steps.push('You have the latest versions of Ops Manager and Elastic Runtime')
        else
          instruction_steps.push('You have the latest version of Ops Manager installed.')
          instruction_steps.push('Upgrade Elastic Runtime to version ' + latest_cf_version)
        end
      else
        opsmgr_instruction = 'You seem to have an Ops Manager version that is more recent than the latest version I know.'
        instruction_steps.push(opsmgr_instruction)
      end

      i = 1
      puts 'Here are your upgrade instructions. Best of luck!'.green
      instruction_steps.each do |x|
        puts (i.to_s + '. ' + x).white
        i = i+1
      end
    end
  end
end