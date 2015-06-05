module Upgrademe
  class OtherProductsLatestVersionsMapper
    def map(products,latest_versions)
      map = {}
      products.each do |x|
        map[x] = latest_versions.fetch(x)
      end
      map
    end
  end
end