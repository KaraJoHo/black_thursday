require_relative '../lib/sales_engine.rb'
require_relative '../lib/item_repository.rb'
require_relative '../lib/item.rb'
require_relative '../lib/merchant.rb'
require_relative '../lib/merchant_repository.rb'
require_relative '../lib/sales_analyst'
require 'csv'

RSpec.describe SalesEngine do
  describe '#initialize' do
    it 'exists' do
      files = {
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv',
      }
      se = SalesEngine.new(files)
  
      expect(se).to be_a(SalesEngine)
    end
  
    it 'can have an item repository' do
      files = {
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv',
      }
      se = SalesEngine.new(files)
  
      expect(se.items.all.all?(Item)).to be(true)
    end
  
    it 'can have an merchant repository' do
      files = {
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv',
      }
      se = SalesEngine.new(files)
  
      expect(se.merchants.all.all?(Merchant)).to be(true)
    end
  
    it 'can have a invoice repository' do
      files = {invoices: './data/invoices.csv'}
  
      se = SalesEngine.new(files)
  
      expect(se.invoices.all.all?(Invoice)).to be(true)
      expect(se.invoices).to respond_to(:find_by_id)
    end
    
    it 'can have a transaction repository' do
      files = {transactions: './data/transactions.csv'}
  
      se = SalesEngine.new(files)
  
      expect(se.transactions.all.all?(Transaction)).to be(true)
    end

    it 'can have a customer repository' do
      files = {customers: './data/customers.csv'}
  
      se = SalesEngine.new(files)
  
      expect(se.customers.all.all?(Customer)).to be(true)
    end

    it 'can have a InvoiceItem repository' do
      files = {invoice_items: './data/invoice_items.csv'}
  
      se = SalesEngine.new(files)
  
      expect(se.invoice_items.all.all?(InvoiceItem)).to be(true)
    end

    it 'can initialize an instance with files' do
      se = SalesEngine.from_csv({
        :items     => './data/items.csv',
        :merchants => './data/merchants.csv',
      })
      ir = se.items
      mr = se.merchants
  
      expect(ir).to respond_to(:all)
      expect(mr).to respond_to(:all)
    end
  end

  it 'finds the merchant by id' do
    se = SalesEngine.from_csv({
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
    })

    expect(se.find_merchant_by_id(12334105)).to eq(se.merchants.all[0])
  end

  it 'finds all items by merchant id' do
    se = SalesEngine.from_csv({
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
    })

    expect(se.find_all_items_by_merchant_id(12334105)).to eq(se.items.find_all_by_merchant_id(12334105))
  end

  it 'finds all invoices by merchant id' do
    se = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )

    expect(se.find_all_invoices_by_merchant_id(12334105)).to eq(se.invoices.find_all_by_merchant_id(12334105))
  end

  it 'finds all transactions by invoice id' do
    se = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )

    expect(se.find_all_transactions_by_invoice_id(12334105)).to eq(se.transactions.find_all_by_invoice_id(12334105))
  end

  it 'finds all invoice items by invoice id' do
    se = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )

    expect(se.find_all_invoice_items_by_id(12334105)).to eq(se.invoice_items.find_all_by_invoice_id(12334105))
  end

  it 'can initialize a sales analyst' do
    se = SalesEngine.from_csv({
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
    })

    expect(se.analyst).to be_a(SalesAnalyst)
  end

  it 'can find all invoices by the date' do
    se = SalesEngine.from_csv(:invoices => './data/invoices.csv')
    

    expect(se.find_all_invoices_by_date(Time.parse("2009-02-07"))).to eq([se.invoices.all[0]])
  end

  it 'can find items by item id' do
    se = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )

    expect(se.find_items_by_item_id(12334105)).to eq(se.items.find_by_id(12334105))
  end

  it 'can return the total money amount of an invoice' do
    sales_engine = SalesEngine.from_csv(
      :items     => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices  => './data/invoices.csv',
      :invoice_items => './data/invoice_items.csv',
      :transactions => './data/transactions.csv',
      :customers => './data/customers.csv'
    )

    expect(sales_engine.invoice_total(1)).to eq(21_067.77)
    expect(sales_engine.invoice_total(1).class).to eq(BigDecimal)
  end
end
