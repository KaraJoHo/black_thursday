require_relative '../lib/modules/calculations'
class SalesAnalyst
  include Calculations

  attr_reader :engine,
              :day_hash

  def initialize(engine = nil)
    @engine   = engine
    @day_hash = day_hash
  end

  def average_items_per_merchant
    average(item_amount)
  end

  def item_amount
    merchants.all.map do |merchant|
      @engine.find_all_items_by_merchant_id(merchant.id).length
    end
  end

  def average_items_per_merchant_standard_deviation
    standard_deviation(item_amount, average_items_per_merchant)
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
  
  def average_item_price_std_dev
    standard_deviation(all_merchant_prices, average_average_price_per_merchant)
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
    unless @day_hash
      @day_hash = {'Monday' => 0, 'Tuesday' => 0, 'Wednesday' => 0, 'Thursday' => 0,
        'Friday' => 0, 'Saturday' => 0, 'Sunday' => 0}
    end
    @day_hash
  end

  def days
    invoices.all.map do |invoice|
      invoice.created_at.strftime('%A')
    end
  end

  def invoice_by_days_hash_populate
    days.each do |day|
      @day_hash[day] += 1
    end
    @day_hash
  end

  def top_days
    invoice_by_days_hash_populate
    std_dev = average_invoices_per_day_standard_deviation
    @day_hash.find_all do |day, count|
      count > (invoice_average_per_day + std_dev)
    end
  end

  def invoice_average_per_day
    average(@day_hash.values)
  end

  def top_days_by_invoice_count
    top_days.map do |day|
      day[0]
    end
  end

  def status_array(status)
    invoices.all.find_all do |invoice|
      invoice.status == status
    end
  end
  
  def invoice_status(status)
    ((status_array(status).count / invoices.all.count.to_f) * 100).round(2)
  end

  def average_invoices_per_day_standard_deviation
    standard_deviation(@day_hash.values, invoice_average_per_day)
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
    @engine.merchants.all.each_with_object({}) do |merchant, hash|
      hash[merchant] = merchant.total_revenue
    end
  end

  def ranked_merchants_with_revenue
    merchant_revenue_hash.sort_by do |k,v|
      -v
    end
  end

  def ranked_merchants
    ranked_merchants_with_revenue.map do |merch_arr|
      merch_arr[0]
    end
  end

  def upper_bound(int)
    int - 1
  end

  def top_revenue_earners(merch_num = 20)
    ranked_merchants[0..upper_bound(merch_num)]
  end

  def merchants_with_pending_invoices
    merchants.all.find_all do |merchant|
      merchant.invoices.any? do |invoice|
        !invoice_paid_in_full?(invoice.id) # comeback and refactor
      end
    end
  end

  def merchants_with_only_one_item
    merchants.all.find_all do |merchant|
      merchant.items.length == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      merchant.created_at.strftime('%B') == month
    end
  end

  def revenue_by_merchant(merchant_id)
    merchant = merchants.find_by_id(merchant_id)
    merchant.total_revenue
  end

  def most_sold_item_for_merchant(merchant_id)
    top_items_by_quantity(merchant_id).map do |item|
      item.first
    end
  end

  def best_item_for_merchant(merchant_id)
    top_items_by_revenue(merchant_id).map do |item|
      item.first
    end
  end

  def paid_invoice_items(merchant_id)
    merchant = merchants.find_by_id(merchant_id)
    merchant.invoices.flat_map do |invoice|
      return unless invoice_paid_in_full?(invoice.id)
      @engine.find_all_invoice_items_by_id(invoice.id)
    end
  end

  def item_quantity_hash(merchant_id)
    paid_invoice_items(merchant_id).each_with_object({}) do |invoice_item, hash|
      if hash.key?(invoice_item.items)
        hash[invoice_item.items] += invoice_item.quantity
      else
        hash[invoice_item.items] = invoice_item.quantity
      end
    end
  end

  def item_revenue_hash(merchant_id)
    paid_invoice_items(merchant_id).each_with_object({}) do |invoice_item, hash|
      if hash.key?(invoice_item.items)
        hash[invoice_item.items] += invoice_item.quantity * invoice_item.unit_price
      else
        hash[invoice_item.items] = invoice_item.quantity  * invoice_item.unit_price
      end
    end
  end

  def max_quantity(merchant_id)
    item_quantity_hash(merchant_id).max_by do |k, v|
      v
    end.last
  end

  def top_items_by_quantity(merchant_id)
    item_quantity_hash(merchant_id).find_all do |k, v|
       v == max_quantity(merchant_id)
    end
  end

  def max_revenue(merchant_id)
    item_revenue_hash(merchant_id).max_by do |k, v|
      v
    end.last
  end

  def top_items_by_revenue(merchant_id)
    item_revenue_hash(merchant_id).find_all do |k, v|
       v == max_revenue(merchant_id)
    end
  end
end
