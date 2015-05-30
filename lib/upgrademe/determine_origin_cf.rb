require 'highline'

module Upgrademe
class DetermineOriginCF
  # Determine what version of Elastic Runtime we're starting with
  def ask(opsmgrvers)

    if opsmgrvers == 1.3
    choose do |menu|
      menu.prompt = 'Which version of Elastic Runtime do you have currently?'
      menu.choice('1.4.3')
      menu.choice('1.4.2')
      menu.choice('1.4.1')
      menu.choice('1.4.0')
      menu.choice('1.3.5')
      menu.choice('1.3.4')
      menu.choice('1.3.3')
      menu.choice('1.3.2')
      menu.choice('1.3.1')
      menu.choice('1.3.0')
    end
    end

  end
end
end