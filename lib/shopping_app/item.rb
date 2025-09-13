# item class
class Item
  attr_reader :name, :price
  attr_accessor :number, :quantity, :owner

  @@instances = []

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name
    @price = price.to_i
    @quantity = quantity.to_i
    @owner = owner
    @@instances << self
  end

  def id
    @number
  end

  def label
    { name: @name, price: @price }
  end

  def self.instances
    @@instances
  end
end
