require './lib/merchant'

class MerchantRepository
  attr_reader :all
  def initialize
    @all = []
  end

  def add_merchant(merchant_object)
    @all << merchant_object
  end

  def find_by_id(id)
    @all.find do |merchant|
      merchant.id == id
    end
  end

  def find_by_name(name)
    @all.find do |merchant|
      name.casecmp(merchant.name) == 0
    end
  end

  def find_all_by_name(name)
    @all.find_all do |merchant|
      name.casecmp(merchant.name) == 0
    end
  end

  def create(attributes)
    new = Merchant.new(attributes)
    require 'pry'; binding.pry
    new.id = @all.map do |merchant|
      # merchant.id.max_by
    end
  end
end
