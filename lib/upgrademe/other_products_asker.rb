require 'yaml'
require 'highline'

module Upgrademe
  class OtherProductsAsker
    def ask(latest_filepath)
      other_products = YAML.load_file(latest_filepath).keys
      other_products.delete('cf')
      other_products.each
      more_products = true
      products_installed=[]
      while more_products && other_products.any?
        say("<%= color('Available Pivotal products to choose from: ',CYAN) %>")
        puts('')
        choose do |menu|
          menu.choice('I have none of the below products') { more_products = false }
          menu.prompt = 'Which product do you have? (Please pick one at time)'
          other_products.each do |x|
            menu.choice(x) { other_products.delete(x); products_installed.push(x) }
          end
        end
      end
      products_installed
    end
  end
end