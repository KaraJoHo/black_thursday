require_relative '../lib/modules/calculations'
class SalesAnalyst
  include Calculations
  attr_reader :engine
  def initialize(engine = nil)
    @engine   = engine
    @day_hash = day_hash
  end

  def average_items_per_merchant
    average(item_amount)
  end

  def average_items_per_merchant_standard_deviation
    standard_deviation(item_amount, average_items_per_merchant)
  end

  def average_item_price_std_dev
    standard_deviation(all_merchant_prices, average_average_price_per_merchant)
  end

  def item_amount
    merchants.all.map do |merchant|
      @engine.find_all_items_by_merchant_id(merchant.id).length
    end
  end

  def merchants_with_high_item_count
    std_dev = average_items_per_merchant_standard_deviation
    merchants.all.find_all do |merchant|
      merchant.items.length >
      (average_items_per_merchant + std_dev)
    end
  end

  def average_item_price_for_merchant(merchant_id)
    average(prices(merchant_id))
  end

  def merchant_averages
    merchants.all.map do |merchant|
      average_item_price_for_merchant(merchant.id)
    end
  end

  def average_average_price_per_merchant
    average(merchant_averages)
  end

  def prices(merchant_id)
    merchants.find_by_id(merchant_id).items.map do |item|
      item.unit_price
    end
  end

  def all_merchant_prices
    merchants.all.flat_map do |merchant|
      prices(merchant.id)
    end
  end

  def golden_items
    std_dev = average_item_price_std_dev
    items.all.find_all do |item|
      item.unit_price  >
      (std_dev *
      2 +
      average_average_price_per_merchant)
    end
  end

  def average_invoices_per_merchant
    average(invoice_amount)
  end

  def invoice_amount
    merchants.all.map do |merchant|
      @engine.find_all_invoices_by_merchant_id(merchant.id).length
    end
  end

  def average_invoices_per_merchant_standard_deviation
    standard_deviation(invoice_amount, average_invoices_per_merchant)
  end

  def top_merchants_by_invoice_count
    std_dev = average_invoices_per_merchant_standard_deviation
    merchants.all.find_all do |merchant|
      merchant.invoices.length > (average_invoices_per_merchant + std_dev * 2)
    end
  end

  def bottom_merchants_by_invoice_count
    std_dev = average_invoices_per_merchant_standard_deviation
    merchants.all.find_all do |merchant|
      merchant.invoices.length < (average_invoices_per_merchant - std_dev * 2)
    end
  end

  def day_hash
    { 'Monday' => 0, 'Tuesday' => 0, 'Wednesday' => 0, 'Thursday' => 0,
      'Friday' => 0, 'Saturday' => 0, 'Sunday' => 0
    }
  end

  def days
    invoices.all.map do |invoice|
      invoice.created_at.strftime('%A')
    end
  end

  def top_days
    invoice_by_days_hash_populate
    std_dev = average_invoices_per_day_standard_deviation
    @day_hash.find_all do |day, count|
      count > (invoice_average_per_day + std_dev)
    end
  end
  
  def invoice_by_days_hash_populate
    days.each do |day|
      @day_hash[day] += 1
    end
  end

  def status_array(status)
    invoices.all.find_all do |invoice|
      invoice.status == status
    end
  end

  def invoice_average_per_day
    average(@day_hash.values)
  end

  def average_invoices_per_day_standard_deviation
    standard_deviation(@day_hash.values, invoice_average_per_day)
  end

  def top_days_by_invoice_count
    top_days.map do |day|
      day[0]
    end
  end

  def invoice_status(status)
    ((status_array(status).count / invoices.all.count.to_f) * 100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
    transactions = @engine.find_all_transactions_by_invoice_id(invoice_id)
    transactions.any? do |transaction|
      transaction.result == :success 
    end
  end

  def invoice_total(invoice_id)
    return unless invoice_paid_in_full?(invoice_id)
    invoice_items = @engine.find_all_invoice_items_by_id(invoice_id)
    invoice_items.map do |item|
      item.unit_price * item.quantity
    end.sum
  end

  def total_revenue_by_date(date)
    invoices = @engine.find_all_invoices_by_date(date)
    invoices.map do |invoice|
      invoice_total(invoice.id)
    end.sum
  end

  def merchant_revenue_hash
    hash = {}
    @engine.merchants.all.each do |merchant|
      hash[merchant] = merchant.total_revenue
    end
    hash
  end

  def top_revenue_earners(x = 20)
    hash = {}
    @engine.merchants.all.each do |merchant|
      hash[merchant] = merchant.total_revenue
    end
    sorted = hash.sort_by do |k,v|
      -v 
    end
    merchants = sorted.map do |merch_arr|
      merch_arr[0]
    end
    upper_bound = (x - 1)
    final = merchants[0..upper_bound]
  end
end
