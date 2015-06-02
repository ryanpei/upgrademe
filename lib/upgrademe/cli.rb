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
      require 'upgrademe/check_cf_upgrades_before_opsmgr'
      instruction_steps = Array.new

      original_opsmgr = Upgrademe::DetermineOriginOpsMgr.new.ask(File.join($CONFIG_PATH,'opsmgr_versions.yml'))
      original_opsmgr_version = original_opsmgr.first
      origin_installation_version = original_opsmgr.last
      origin_filepath = File.join($CONFIG_PATH, 'installation_version_' + origin_installation_version.to_s.gsub(/[.]/,'_') + '.yml')
      original_cf = Upgrademe::DetermineOriginCF.new.ask(origin_filepath)

      latest_versions = YAML.load_file(File.join($CONFIG_PATH,'latest_versions.yml'))
      latest_opsmgr_version = latest_versions.fetch('opsmgr')
      latest_installation_version = YAML.load_file(File.join($CONFIG_PATH,'opsmgr_versions.yml')).fetch(latest_opsmgr_version).fetch('installation_version')
      latest_filepath = File.join($CONFIG_PATH, 'installation_version_' + latest_installation_version.to_s.gsub(/[.]/,'_') + '.yml')

      latest_cf_version = latest_versions.fetch('cf')

      if Gem::Version.new(original_opsmgr_version) < Gem::Version.new(latest_opsmgr_version)
        opsmgr_instructions = 'Upgrade your Ops Manager to version ' + latest_opsmgr_version
        cf_step_required = true
        result = Upgrademe::CheckCFUpgradesBeforeOpsmgr.new.getinstructions(original_cf,latest_cf_version,latest_filepath,origin_filepath)

        while cf_step_required

          if result.first
            instruction_steps.push('Upgrade Elastic Runtime to version ' + result.last)
            result = Upgrademe::CheckCFUpgradesBeforeOpsmgr.new.getinstructions(result.last,latest_cf_version,latest_filepath,origin_filepath)
          else
            instruction_steps.push(opsmgr_instructions)
            instruction_steps.push('Upgrade Elastic Runtime to version ' + result.last)
            cf_step_required = false
          end
        end

      elsif Gem::Version.new(original_opsmgr_version) == Gem::Version.new(latest_opsmgr_version)
        opsmgr_instruction = 'You have the latest version of Ops Manager installed.'
        instruction_steps.push(opsmgr_instruction)
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

      #if Gem::Version.new(original_cf) < Gem::Version.new(latest_cf_version)
       # print YAML.load_file(filepath).fetch('cf').keys.include?(latest_cf_version)
      #end

    end
  end
end
