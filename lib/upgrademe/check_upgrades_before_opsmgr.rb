require 'yaml'

module Upgrademe
  class CheckUpgradesBeforeOpsmgr
    def check(product, original_vers, latest_vers, latest_filepath, origin_filepath)

      migrations_to_latest_cf = YAML.load_file(latest_filepath).fetch(product).fetch(latest_vers).fetch('upgrades_from')
      if migrations_to_latest_cf.include?(original_vers)
        q = [false, latest_vers]
      else
        intermediary = YAML.load_file(origin_filepath).fetch(product)
        intermediate_vers = intermediary.keys.last
        no_migration_present = true
        i = 0
        while no_migration_present
          intermediate_migrations = intermediary.fetch(intermediate_vers).fetch('upgrades_from')
          if intermediate_migrations.include?(original_vers)
            q = [true, intermediate_vers]
            no_migration_present = false
          else
            i = i+1
            intermediate_vers = intermediary.keys[0-i]
          end
        end
      end
      q
    end
  end
end