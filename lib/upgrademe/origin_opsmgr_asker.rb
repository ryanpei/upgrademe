require 'highline/import'
require 'yaml'

module Upgrademe
  class OriginOpsmgrAsker
    # Determine what version of Ops Mgr we're starting with
    def ask(filepath)
      hash = Hash.new
      opsmgrs = YAML.load_file(filepath)
      q = choose do |menu|
        say("<%= color('Available versions of PCF Ops Manager',CYAN) %>")
        menu.prompt = 'Which version of Ops Manager do you have currently?'
        opsmgrs.each do |x|
          menu.choice(x.first)
          hash[x.first] = x.last.fetch('installation_version')
        end
      end
      [q,hash[q]]
    end

  end
end
