require 'thor'
require 'yaml'
require 'colorize'

module Upgrademe
  class Cli < Thor

    $CONFIG_PATH = Dir.pwd + '/config'

    def self.exit_on_failure?
      true
    end

    desc 'test', 'Testing this ruby thing out'

    def test()
      say('I am alive!')
    end

    desc 'to-latest', 'Get all my products to their latest versions'

    def to_latest
      require 'upgrademe/determine_origin_opsmgr'
      require 'upgrademe/determine_origin_cf'
      require 'upgrademe/check_upgrades_before_opsmgr'
      require 'upgrademe/other_product_upgrade_validator'

      instruction_steps = []

      original_opsmgr = Upgrademe::DetermineOriginOpsMgr.new.ask(File.join($CONFIG_PATH, 'opsmgr_versions.yml'))
      original_opsmgr_version = original_opsmgr.first
      origin_installation_version = original_opsmgr.last
      origin_filepath = File.join($CONFIG_PATH, 'installation_version_' + origin_installation_version.to_s.gsub(/[.]/, '_') + '.yml')
      original_cf_version = Upgrademe::DetermineOriginCF.new.ask(origin_filepath)

      #temporary values here
      other_tiles_original = {'p-mysql' => '1.3.2', 'p-redis' => '1.3.2'}
      other_tiles_final = {'p-mysql' => '1.5.0', 'p-redis' => '1.4.4'}
      #other_tiles_original = {}
      #other_tiles_final = {}

      latest_versions = YAML.load_file(File.join($CONFIG_PATH, 'latest_versions.yml'))
      latest_opsmgr_version = latest_versions.fetch('opsmgr')
      latest_installation_version = YAML.load_file(File.join($CONFIG_PATH, 'opsmgr_versions.yml')).fetch(latest_opsmgr_version).fetch('installation_version')
      latest_filepath = File.join($CONFIG_PATH, 'installation_version_' + latest_installation_version.to_s.gsub(/[.]/, '_') + '.yml')

      latest_cf_version = latest_versions.fetch('cf')

      cf_step_required = Gem::Version.new(original_cf_version) < Gem::Version.new(latest_cf_version)
      opsmgr_upgrade_required = Gem::Version.new(original_opsmgr_version) < Gem::Version.new(latest_opsmgr_version)
      opsmgr_up_to_date = Gem::Version.new(original_opsmgr_version) == Gem::Version.new(latest_opsmgr_version)
      product_upgrades_req = Upgrademe::OtherProductUpgradeValidator.new.requiredornot(other_tiles_original, other_tiles_final)

      if opsmgr_upgrade_required
        opsmgr_instructions = 'Upgrade your Ops Manager to version ' + latest_opsmgr_version
        cf_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check('cf', original_cf_version, latest_cf_version, latest_filepath, origin_filepath)
        other_products_results = Array.new

        other_product_needs_mediation = false
        other_tiles_original.keys.each do |x|
          other_products_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check(x, other_tiles_original.fetch(x), other_tiles_final.fetch(x), latest_filepath, origin_filepath)
          other_products_results.push(other_products_result)
        end


        while cf_step_required || product_upgrades_req

          if cf_result.first
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)

            #other_products_results.each do |x|

            #end
          elsif other_product_needs_mediation

          else
            instruction_steps.push(opsmgr_instructions)
            instruction_steps.push('Upgrade Elastic Runtime to version ' + cf_result.last)
            cf_step_required = false
            product_upgrades_req = false
          end
          cf_result = Upgrademe::CheckUpgradesBeforeOpsmgr.new.check('cf', cf_result.last, latest_cf_version, latest_filepath, origin_filepath)
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
