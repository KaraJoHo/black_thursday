require_relative '../lib/invoice_repository'
require_relative '../lib/invoice'

RSpec.describe InvoiceRepository do
  it 'exists' do
    ivr = InvoiceRepository.new

    expect(ivr).to be_a(InvoiceRepository)
  end  

  it 'starts with no invoices' do
    ivr = InvoiceRepository.new

    expect(ivr.data).to eq([])
  end
  describe '#module methods' do
    it 'can return all invoices' do
      ivr = InvoiceRepository.new
  
      i = Invoice.new(
        :id          => 6,
        :customer_id => 7,
        :merchant_id => 8,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )
  
      ivr.all << i 
  
      expect(ivr.all).to eq([i])
    end

    it 'can find invoices by id' do
      ivr = InvoiceRepository.new
      i = Invoice.new(
        :id          => 6,
        :customer_id => 7,
        :merchant_id => 8,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )

      ivr.all << i 

      expect(ivr.find_by_id(6)).to eq(i)
      expect(ivr.find_by_id(2)).to eq(nil)
    end

    it 'can find all invoices by merchant id' do
      ivr = InvoiceRepository.new
      i1 = Invoice.new(
        :id          => 6,
        :customer_id => 7,
        :merchant_id => 8,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )
      i2 = Invoice.new(
        :id          => 5,
        :customer_id => 7,
        :merchant_id => 8,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )
      i3 = Invoice.new(
        :id          => 5,
        :customer_id => 7,
        :merchant_id => 10,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )

      ivr.all.push(i1,i2,i3)

      expect(ivr.all).to eq([i1,i2,i3])
      expect(ivr.find_all_by_merchant_id(8)).to eq([i1,i2])
    end

    it 'can delete invoices' do
      ivr = InvoiceRepository.new
      i = Invoice.new(
        :id          => 6,
        :customer_id => 7,
        :merchant_id => 8,
        :status      => "pending",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s
      )

      ivr.all << i 

      expect(ivr.all).to eq([i])

      ivr.delete(6)

      expect(ivr.all).to eq([])
    end
  end
end
