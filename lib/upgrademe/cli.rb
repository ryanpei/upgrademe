require 'thor'
require 'yaml'

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
      original_opsmgr = Upgrademe::DetermineOriginOpsMgr.new.ask
      if original_opsmgr == '1.4.0' || '1.4.1' || '1.4.2'
        filepath = File.join($CONFIG_PATH, 'opsmgr_1_4.yml')
        possible_cf_versions = YAML.load_file(filepath)

        original_cf = Upgrademe::DetermineOriginCF.new.ask(possible_cf_versions)
      end
      print original_opsmgr
      print original_cf

    end
  end
end
