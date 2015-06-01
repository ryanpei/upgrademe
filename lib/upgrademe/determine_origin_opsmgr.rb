require 'highline/import'

module Upgrademe
  class DetermineOriginOpsMgr
    # Determine what version of Ops Mgr we're starting with
    def ask
      q = choose do |menu|
        menu.header = 'Available versions of PCF Ops Manager'
        menu.prompt = 'Which version of Ops Manager do you have currently?'
        menu.choice('1.4.2')
        menu.choice('1.4.1')
        menu.choice('1.4.0')
        menu.choice('1.3.4')
      end
      q
    end

  end
end
