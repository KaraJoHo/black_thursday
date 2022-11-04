class SalesAnalyst
  attr_reader :engine
  def initialize(engine = nil)
    @engine = engine
  end
  def average_items_per_merchant
    # require 'pry' ; binding.pry
    (item_amount.sum / item_amount.length.to_f).round(2)
  end

  def average_items_per_merchant_standard_deviation
    Math.sqrt(divide_diff_and_square_sum).round(2)
  end

  def item_amount
    @engine.merchants.all.map do |merchant|
      @engine.find_all_by_merchant_id(merchant.id).length
    end
  end

  def diff_and_square
    item_amount.map do |amount|
      (amount - average_items_per_merchant)**2
    end
  end

  def diff_and_square_sum
    diff_and_square.sum
  end

  def divide_diff_and_square_sum
    diff_and_square_sum / (item_amount.length - 1)
  end




end
