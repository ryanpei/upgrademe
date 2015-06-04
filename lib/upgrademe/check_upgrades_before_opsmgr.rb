require 'yaml'

module Upgrademe
class CheckUpgradesBeforeOpsmgr
  def check(product,original_vers,latest_vers,latest_filepath,origin_filepath)
    migrations_to_latest_cf = YAML.load_file(latest_filepath).fetch(product).fetch(latest_vers).fetch('upgrades_from')
    if migrations_to_latest_cf.include?(original_vers)
      q = [false,latest_vers]
    else
      intermediary = YAML.load_file(origin_filepath).fetch(product)
      intermediate_vers = intermediary.keys.last
      intermediate_migrations = intermediary.fetch(intermediate_vers).fetch('upgrades_from')
      if intermediate_migrations.include?(original_vers)
        q = [true,intermediate_vers]
      end
    end
    q
  end
end
end