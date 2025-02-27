require_relative '../lib/sales_engine.rb'
require_relative '../lib/item_repository.rb'
require_relative '../lib/item.rb'
require_relative '../lib/merchant.rb'
require_relative '../lib/sales_analyst'
require 'csv'
require 'bigdecimal'

RSpec.describe SalesAnalyst do
  describe '#initialize' do
    it 'exists' do
      sales_analyst = SalesAnalyst.new
  
      expect(sales_analyst).to be_a(SalesAnalyst)
    end
  
    it 'has a sales engine' do
      sales_engine = SalesEngine.from_csv({
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv'
      })
      sales_analyst = sales_engine.analyst
  
      expect(sales_analyst.engine).to be_a(SalesEngine)
    end

    it 'starts with a hash of days of the week' do
      sales_engine = SalesEngine.from_csv({
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv'
      })
      sales_analyst = sales_engine.analyst
      expect(@day_hash).to eq(nil)
      sales_analyst.day_hash
      expect(sales_analyst.day_hash.class).to eq(Hash)
      expect(sales_analyst.day_hash.keys.include?("Monday")).to be(true)
    end
  end

  describe '#module methods' do
    it 'Take the difference between each number and the mean, then square it.' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/items_test.csv',
        :merchants => './data/test_data/merchant_test.csv'
      )
      sales_analyst = sales_engine.analyst
  
      expect(sales_analyst.diff_and_square(sales_analyst.item_amount, sales_analyst.average_items_per_merchant)).to eq([1,0,1])
    end
  
    it "gets the sum from #diff_and_square" do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/items_test.csv',
        :merchants => './data/test_data/merchant_test.csv'
      )
      sales_analyst = sales_engine.analyst
  
      expect(sales_analyst.diff_and_square_sum(sales_analyst.item_amount, sales_analyst.average_items_per_merchant)).to eq(2)
  
    end
  
    it 'Divide the sum by the number of elements minus 1.' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/items_test.csv',
        :merchants => './data/test_data/merchant_test.csv'
      )
      sales_analyst = sales_engine.analyst
  
      expect(sales_analyst.divide_diff_and_square_sum(sales_analyst.item_amount, sales_analyst.average_items_per_merchant)).to eq(1)
    end

    it 'can calculate the standard deviation of arrays with their average' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/items_test.csv',
        :merchants => './data/test_data/merchant_test.csv'
      )
      sales_analyst = sales_engine.analyst

      amounts = [3,4,5]
      average = sales_analyst.average(amounts)

      expect(sales_analyst.standard_deviation(amounts, average)).to eq(1)
    end

    it 'can calculate average given an array of values' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/items_test.csv',
        :merchants => './data/test_data/merchant_test.csv'
      )
      sales_analyst = sales_engine.analyst

      amount = [3,4,5]

      expect(sales_analyst.average(amount)).to eq(4)
    end

    it 'can return a merchant repository' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
        :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
        :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
        :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
        :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
        :customers => './data/customers.csv'
      )
      sales_analyst = sales_engine.analyst

      expect(sales_analyst.merchants.class).to eq(MerchantRepository)
    end

    it 'can return a item repository' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
        :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
        :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
        :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
        :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
        :customers => './data/customers.csv'
      )
      sales_analyst = sales_engine.analyst

      expect(sales_analyst.items.class).to eq(ItemRepository)
    end

    it 'can return a invoice repository' do
      sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
        :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
        :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
        :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
        :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
        :customers => './data/customers.csv'
      )
      sales_analyst = sales_engine.analyst

      expect(sales_analyst.invoices.class).to eq(InvoiceRepository)
    end
  end

  it 'calculates the average items per merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_items_per_merchant).to eq(2.88)
  end

  it 'returns an array of item amounts for every merchant' do
    sales_engine = SalesEngine.from_csv(
        :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
        :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
        :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
        :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
        :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
        :customers => './data/customers.csv'
      )
      sales_analyst = sales_engine.analyst

      expected = sales_analyst.item_amount

      expect(expected.all?(Numeric)).to be(true)
  end


  it 'returns the standard deviation' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_test.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_items_per_merchant_standard_deviation).to eq(1.0)
  end
  
  it 'returns the merchants with high item counts' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test2.csv',
      :merchants => './data/test_data/merchant_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.merchants_with_high_item_count).to eq([sales_engine.merchants.all[-1]])
  end

  it 'finds the average price of a merchants items' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test2.csv',
      :merchants => './data/test_data/merchant_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_item_price_for_merchant(12334105)).to eq(13.0)
    expect(sales_analyst.average_item_price_for_merchant(12334105)).to be_a(BigDecimal)
  end

  it 'returns an array of average item prices for each merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test2.csv',
      :merchants => './data/test_data/merchant_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.merchant_averages

    expect(expected.all?(Numeric)).to be(true)
  end

  it 'sums all the averages, and find the average across all merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_test.csv'
     )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_average_price_per_merchant).to eq(13.67)
  end

  it 'finds the item prices of a merchant by its id' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_test.csv'
    )
    sales_analyst = sales_engine.analyst
    
    expect(sales_analyst.prices(12334105)).to eq([12.0, 13.0, 14.0])
  end
  
  it 'finds each merchants item prices' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_test.csv'
    )
    sales_analyst = sales_engine.analyst
    
    expect(sales_analyst.all_merchant_prices).to eq([0.12e2, 0.13e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2, 0.14e2])
  end

  it 'returns average item price per merchant standard deviation' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test2.csv',
      :merchants => './data/test_data/merchant_test2.csv'
      )
    sales_analyst = sales_engine.analyst
    sales_analyst.all_merchant_prices

    expect(sales_analyst.average_item_price_std_dev).to eq(0.43)
  end
  
  it 'returns golden items' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test3.csv',
      :merchants => './data/test_data/merchant_test3.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.golden_items).to eq([sales_engine.items.all[15], sales_engine.items.all[26]])
  end

  it 'can calculate average invoices per merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test.csv',
      :invoices  => './data/test_data/invoices_test.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_invoices_per_merchant).to eq(4)
  end

  it 'returns an array of invoice amounts for all merchants' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test.csv',
      :invoices  => './data/test_data/invoices_test.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.invoice_amount

    expect(expected).to eq([3,4,5])
  end

  it 'can calculate average invoices per merchant standard deviation' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test.csv',
      :invoices  => './data/test_data/invoices_test.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.average_invoices_per_merchant_standard_deviation).to eq(1.00)
  end

  it 'can return the top performing merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test2.csv',
      :invoices  => './data/test_data/invoices_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.top_merchants_by_invoice_count).to eq([sales_engine.merchants.all[-1]])
  end

  it 'can return the lowest performing merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test3.csv',
      :invoices  => './data/test_data/invoices_test3.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.bottom_merchants_by_invoice_count).to eq([sales_engine.merchants.all[0]])
  end

  it 'returns an array of the days all invoices were created at' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test3.csv',
      :invoices  => './data/test_data/invoices_test3.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.days

    expect(expected.include?("Saturday")).to be(true)
    expect(expected.include?("Monday")).to be(true)
    expect(expected.include?("Friday")).to be(true)
  end

  it 'populates day hash with the counts of every invoice day' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test3.csv',
      :invoices  => './data/test_data/invoices_test3.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.invoice_by_days_hash_populate

    expect(expected).to eq({
                             "Friday"=>20, "Monday"=>10, "Saturday"=>11,
                             "Sunday"=>0, "Thursday"=>0, "Tuesday"=>0, "Wednesday"=>10
                             })
  end

  it 'returns day with counts where count is higher than than 1 std deviation' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test3.csv',
      :invoices  => './data/test_data/invoices_test3.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.top_days

    expect(expected).to eq([["Friday", 20]])
  end

  it 'calculates the average of invoice averages per day' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test3.csv',
      :invoices  => './data/test_data/invoices_test3.csv'
    )
    sales_analyst = sales_engine.analyst
    sales_analyst.invoice_by_days_hash_populate
    expected = sales_analyst.invoice_average_per_day

    expect(expected).to eq(7.29)
  end

  it 'can return the top days of the week by invoice count' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test2.csv',
      :invoices  => './data/test_data/invoices_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.top_days_by_invoice_count).to eq(['Monday'])
  end

  it 'returns an array of invoices that have the status' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test2.csv',
      :invoices  => './data/test_data/invoices_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.status_array(:pending).all?(Invoice)).to be(true)
  end

  it 'can calculate percentages by the status' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test2.csv',
      :invoices  => './data/test_data/invoices_test2.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.invoice_status(:pending)).to eq(76.19)
    expect(sales_analyst.invoice_status(:shipped)).to eq(9.52)
    expect(sales_analyst.invoice_status(:returned)).to eq(14.29)
  end

  it 'can check if an invoice is paid in full' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/items_test.csv',
      :merchants => './data/test_data/merchant_invoices_test2.csv',
      :invoices  => './data/test_data/invoices_transactions_test.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/test_data/transactions_test.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.invoice_paid_in_full?(1)).to be(true)
    expect(sales_analyst.invoice_paid_in_full?(2)).to be(false)
    expect(sales_analyst.invoice_paid_in_full?(4)).to be(false)
  end

  it 'can return the total $ amount of an invoice' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.invoice_total(1)).to eq(21_067.77)
    expect(sales_analyst.invoice_total(1).class).to eq(BigDecimal)
  end

  it 'can find total revenue by the date' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.total_revenue_by_date(Time.parse("2009-02-07"))).to eq(21_067.77)
    expect(sales_analyst.total_revenue_by_date(Time.parse("2022-11-07"))).to eq(0)
  end

  it 'returns a hash of all merchants with their total revenue' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    expected = sales_analyst.merchant_revenue_hash
    expect(expected.class).to eq(Hash)
    expect(expected.keys.all?(Merchant)).to be(true)
    expect(expected.values.all?(Numeric)).to be(true)
  end

  it 'ranks the merchants with revenue' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    expected = sales_analyst.ranked_merchants_with_revenue
    first_arr = expected.first

    expect(first_arr[0].id).to eq(12334634)
    expect(first_arr[1].class).to eq(BigDecimal)
  end

  it 'returns an array of merchants ranked by revenue' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    expected = sales_analyst.ranked_merchants

    expect(expected.all?(Merchant)).to be(true)
    expect(expected.first.id).to eq(12334634)
  end

  it 'returns one less than the integer input' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    expected = sales_analyst.upper_bound(20)

    expect(expected).to eq(19)
  end

  it 'can find top 20 revenue earners or a specified amount' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expected = sales_analyst.top_revenue_earners(10)
    first = expected.first
    last = expected.last

    expect(expected.length).to eq(10)
    expect(first.id).to eq 12334634
    expect(last.id).to eq 12335747

    expected = sales_analyst.top_revenue_earners
    first = expected.first
    last = expected.last

    expect(expected.length).to eq(20)
    expect(first.id).to eq 12334634
    expect(last.id).to eq 12334159
  end

  it 'can will return an array of merchants with pending invoices' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/test_data/merchant_test4.csv',
      :invoices  => './data/test_data/invoices_transactions_test.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/test_data/transactions_test.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.merchants_with_pending_invoices.length).to eq(1)
    expect(sales_analyst.merchants_with_pending_invoices.first.class).to eq(Merchant)
    expect(sales_analyst.merchants_with_pending_invoices[0].name).to eq('Candisart')
  end

  it 'can return an array of merchants with only one item' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/test_data/merchant_test4.csv',
      :invoices  => './data/test_data/invoices_transactions_test.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/test_data/transactions_test.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.merchants_with_only_one_item.length).to eq (1)
  end

  it 'can find merchants with only one item registered in month' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/test_data/merchant_test4.csv',
      :invoices  => './data/test_data/invoices_transactions_test.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/test_data/transactions_test.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.merchants_with_only_one_item_registered_in_month("May")[0].name).to eq ("Candisart")
  end

  it 'can find revenue by merchant id' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/test_data/merchant_test4.csv',
      :invoices  => './data/test_data/invoices_transactions_test.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/test_data/transactions_test.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.revenue_by_merchant(12335938)).to eq(0.2106777e5)
  end

  it 'can find the most sold item for a merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.most_sold_item_for_merchant(1)[0].name).to eq('TestItem2')
    expect(sales_analyst.most_sold_item_for_merchant(1)[1].name).to eq('TestItem3')
  end

  it 'can find the best item for a merchant' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.best_item_for_merchant(1)[0].name).to eq('TestItem3')
  end

  it 'can find paid invoice items' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.paid_invoice_items(1).all?(InvoiceItem)).to be(true)
  end

  it 'returns a hash with items and quantitys' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.item_quantity_hash(1).keys.all?(Item)).to be(true)
    expect(sales_analyst.item_quantity_hash(1).values.all?(Integer)).to be(true)
  end

  it 'adds to pre existing hash items quantities' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    testitem1 = sales_engine.find_all_items_by_merchant_id(1)[0]
    expect(sales_analyst.item_quantity_hash(1)[testitem1]).to eq(8)
  end

  it 'adds to pre existing hash items revenue' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst
    testitem1 = sales_engine.find_all_items_by_merchant_id(1)[0]
    expect(sales_analyst.item_revenue_hash(1)[testitem1]).to eq(8.0)
  end

  it 'returns a hash with items and revenue' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.item_revenue_hash(1).keys.all?(Item)).to be(true)
    expect(sales_analyst.item_revenue_hash(1).values.all?(BigDecimal)).to be(true)
  end

  it 'returns the maximum quantity of all items'  do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.max_quantity(1)).to eq (9)
  end

  it 'returns the top items by max quantity'  do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.top_items_by_quantity(1).length).to eq (2)
  end

  it 'returns the maximum revenue of all items'  do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.max_revenue(1)).to eq (3138.57)
  end

  it 'returns the top items by max revenue'  do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/test_data/most_sold_item_for_merchant/items.csv',
      :merchants => './data/test_data/most_sold_item_for_merchant/merchants.csv',
      :invoices  => './data/test_data/most_sold_item_for_merchant/invoices.csv',
      :invoice_items => './data/test_data/most_sold_item_for_merchant/invoiceitems.csv',
      :transactions => './data/test_data/most_sold_item_for_merchant/transactions.csv',
      :customers => './data/customers.csv'
    )
    sales_analyst = sales_engine.analyst

    expect(sales_analyst.top_items_by_revenue(1).length).to eq(1)
  end
end
