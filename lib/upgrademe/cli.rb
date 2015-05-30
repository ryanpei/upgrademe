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
      q = Upgrademe::DetermineOriginOpsMgr.new.ask
      p q

    end
  end
end