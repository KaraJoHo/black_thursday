require 'rspec'
require_relative '../lib/item'
require 'bigdecimal'

describe Item do
  describe '#initialize' do
    it 'exists' do
      i = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => BigDecimal(10.99,4),
        :created_at  => Time.now.to_s,
        :updated_at  => Time.now.to_s,
        :merchant_id => 2
      })

      expect(i).to be_a(Item)
    end

    it 'has attributes' do
      i = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => "1099",
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s,
        :merchant_id => 2
      })

      expect(i.id).to eq(1)
      expect(i.name).to eq("Pencil")
      expect(i.description).to eq("You can use it to write things")
      expect(i.unit_price).to eq(0.1099e2)
      expect(i.created_at).to eq(Time.parse(created))
      expect(i.updated_at).to eq(Time.parse(updated))
      expect(i.merchant_id).to eq(2)
    end
  end

  describe '#unit_price_to_dollars' do
    it 'returns the price of the item in dollars formatted as a float' do
      i = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => '1099',
        :created_at  => created = Time.now.to_s,
        :updated_at  => updated = Time.now.to_s,
        :merchant_id => 2
      })

      expect(i.unit_price_to_dollars).to eq(10.99)
    end
  end

  describe '#time_converter' do
    it 'parses the time' do
      i = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => '1099',
        :created_at  => Time.now.to_s,
        :updated_at  => Time.now.to_s,
        :merchant_id => 2
      })

      expect(i.updated_at).to be_a(Time)
      expect(i.created_at).to be_a(Time)
    end
  end
end
