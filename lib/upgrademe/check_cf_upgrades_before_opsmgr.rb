require 'yaml'

module Upgrademe
class CheckCFUpgradesBeforeOpsmgr
  def getinstructions(original_cf,latest_cf_version,latest_filepath,origin_filepath)
    migrations_to_latest_cf = YAML.load_file(latest_filepath).fetch('cf').fetch(latest_cf_version).fetch('upgrades_from')
    if migrations_to_latest_cf.include?(original_cf)
      q = [false,latest_cf_version]
    else
      #print YAML.load_file(origin_filepath).fetch('cf').keys
      intermediary = YAML.load_file(origin_filepath).fetch('cf')
      intermediate_cf_version = intermediary.keys.last
      intermediate_cf_migrations = intermediary.fetch(intermediate_cf_version).fetch('upgrades_from')
      if intermediate_cf_migrations.include?(original_cf)
        q = [true,intermediate_cf_version]
      end
    end
    q
  end
end
end