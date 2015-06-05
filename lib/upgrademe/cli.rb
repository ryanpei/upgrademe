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
      require 'upgrademe/origin_opsmgr_asker'
      require 'upgrademe/origin_cf_asker'
      require 'upgrademe/instruction_writer'
      require 'upgrademe/other_products_asker'
      require 'upgrademe/other_products_origin_versions_asker'
      require 'upgrademe/other_products_latest_versions_mapper'

      original_opsmgr = Upgrademe::OriginOpsmgrAsker.new.ask(File.join($CONFIG_PATH, 'opsmgr_versions.yml'))
      original_opsmgr_version = original_opsmgr.first
      origin_installation_version = original_opsmgr.last
      origin_filepath = File.join($CONFIG_PATH, 'installation_version_' + origin_installation_version.to_s.gsub(/[.]/, '_') + '.yml')
      original_cf_version = Upgrademe::OriginCfAsker.new.ask(origin_filepath)

      #temporary values here
      #other_tiles_original = {'p-mysql' => '1.3.2', 'p-redis' => '1.3.2'}
      other_tiles_final = {'p-mysql' => '1.5.0', 'p-redis' => '1.4.4'}
      #other_tiles_original = {'p-mysql' => '1.3.2'}
      #other_tiles_final = {'p-mysql' => '1.5.0'}
      #other_tiles_original = {}
      #other_tiles_final = {}

      latest_versions = YAML.load_file(File.join($CONFIG_PATH, 'latest_versions.yml'))
      latest_opsmgr_version = latest_versions.fetch('opsmgr')
      latest_installation_version = YAML.load_file(File.join($CONFIG_PATH, 'opsmgr_versions.yml')).fetch(latest_opsmgr_version).fetch('installation_version')
      latest_filepath = File.join($CONFIG_PATH, 'installation_version_' + latest_installation_version.to_s.gsub(/[.]/, '_') + '.yml')

      latest_cf_version = latest_versions.fetch('cf')

      other_tiles = Upgrademe::OtherProductsAsker.new.ask(latest_filepath)
      other_tiles_original = Upgrademe::OtherProductsOriginVersionsAsker.new.ask(other_tiles,origin_filepath)
      other_tiles_final = Upgrademe::OtherProductsLatestVersionsMapper.new.map(other_tiles,latest_versions)

      instruction_set = Upgrademe::InstructionOrderer.new(original_cf_version,latest_cf_version,latest_opsmgr_version,original_opsmgr_version,other_tiles_original,other_tiles_final,origin_filepath,latest_filepath)
      instruction_set.instruct

    end
  end
end
