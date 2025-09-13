require_relative "ownable" 

class Item
  include Ownable
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

  # Returs a hash of this item's label data
  def label
    { name: @name, price: @price }
  end

  # All instantiated Item objects
  def self.instances
    @@instances
  end
end