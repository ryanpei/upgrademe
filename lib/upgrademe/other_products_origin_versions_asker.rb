require 'yaml'
require 'highline'

module Upgrademe
  class OtherProductsOriginVersionsAsker

    def ask(products, origin_filepath)
      products_with_versions = {}
      products.each do |x|
        product_versions = YAML.load_file(origin_filepath).fetch(x).keys
        say("<%= color('Available versions of #{x} to choose from: ',CYAN) %>")
        puts('')
        my_version = choose do |menu|
          menu.prompt = 'Which version of ' + x + ' do you have installed currently?'
          product_versions.each do |y|
            menu.choice(y)
          end
        end
        products_with_versions[x] = my_version
      end
      products_with_versions
    end

  end
end