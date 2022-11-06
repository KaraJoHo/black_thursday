require_relative '../lib/invoice_item.rb'

RSpec.describe InvoiceItem do

  it 'exists' do
    ii = InvoiceItem.new({
  :id => 6,
  :item_id => 7,
  :invoice_id => 8,
  :quantity => 1,
  :unit_price => BigDecimal(10.99, 4),
  :created_at => Time.now,
  :updated_at => Time.now
    })

    expect(ii).to be_a(InvoiceItem)
  end

  it 'has an id' do
    ii = InvoiceItem.new({
  :id => 6,
  :item_id => 7,
  :invoice_id => 8,
  :quantity => 1,
  :unit_price => BigDecimal(10.99, 4),
  :created_at => Time.now,
  :updated_at => Time.now
    })

    expect(ii.id).to eq(6)
  end

  it 'has an item_id' do
    ii = InvoiceItem.new({
  :id => 6,
  :item_id => 7,
  :invoice_id => 8,
  :quantity => 1,
  :unit_price => BigDecimal(10.99, 4),
  :created_at => Time.now,
  :updated_at => Time.now
    })

    expect(ii.item_id).to eq(7)
  end
end
