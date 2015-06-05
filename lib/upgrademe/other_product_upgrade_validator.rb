module Upgrademe
  class OtherProductUpgradeValidator
    def requiredornot(original_products, final_products)
      required = false
      products_that_need_upgrades = []
      original_products.keys.each do |x|
        if Gem::Version.new(original_products.fetch(x)) < Gem::Version.new(final_products.fetch(x))
          required = true
          products_that_need_upgrades.push(x)
        end
      end
      [required,products_that_need_upgrades]
    end
  end
end