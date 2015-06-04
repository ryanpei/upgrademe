module Upgrademe
  class OtherProductUpgradeValidator
    def requiredornot(original_products, final_products)
      required = false
      original_products.keys.each do |x|
        if Gem::Version.new(original_products.fetch(x)) < Gem::Version.new(final_products.fetch(x))
          required = true
          break
        end
      end
      required
    end
  end
end