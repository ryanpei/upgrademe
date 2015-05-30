require 'thor'

module Upgrademe
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'test', 'Testing this ruby thing out'
    def test()
      say('I am alive!')
    end

    desc 'to-latest', 'Get all my products to their latest versions'
    def to_latest()
      require 'upgrademe/determine_origin_opsmgr'
      original_opsmgr = Upgrademe::DetermineOriginOpsMgr.new.ask
      if original_opsmgr == '1.3.4'
        original_cf = Upgrademe::DetermineOriginCF.new.ask(1.3)
      end
      p original_cf

    end
  end
end