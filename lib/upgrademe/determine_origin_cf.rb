require 'highline'

module Upgrademe
class DetermineOriginCF
  # Determine what version of Elastic Runtime we're starting with
  def ask(possible_cf_versions)
    hash = Hash.new

    q = choose do |menu|
      menu.header = 'Possible versions of Elastic Runtime you have'
      menu.prompt = 'Which version of Elastic Runtime do you have currently?'
      possible_cf_versions.fetch('cf').each do |x|
        menu.choice(x.first)
        hash[x.first] = x.last
      end
    end
    [q,hash[q]]

  end
end
end
