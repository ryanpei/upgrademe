require 'highline'

module Upgrademe
class DetermineOriginCF
  # Determine what version of Elastic Runtime we're starting with
  def ask(filepath)
    #hash = Hash.new
    possible_cf_versions = YAML.load_file(filepath)

    q = choose do |menu|
      say("<%= color('Available versions of PCF Elastic Runtime',CYAN) %>")
      menu.prompt = 'Which version of Elastic Runtime do you have currently?'
      possible_cf_versions.fetch('cf').each do |x|
        menu.choice(x.first)
        #hash[x.first] = x.last
      end
    end
    #[q,hash[q]]
    q
  end
end
end
