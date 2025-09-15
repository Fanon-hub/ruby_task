require_relative "ownable"

class Item
  include Ownable

  attr_reader :number, :name, :price
  attr_accessor :owner, :quantity

  @@instances = []

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name   = name
    @price  = price.to_i
    @quantity = quantity.to_i
    @owner  = owner

    # register this instance (each call creates one Item instance)
    @@instances << self
  end

  # Return the id/number
  def id
    @number
  end

  # Return a hash describing this item
  def label
    { name: @name, price: @price }
  end

  def to_s
    "Item(##{@number}, #{@name}, price: #{@price}, owner: #{@owner&.name})"
  end

  # All instantiated Item objects
  def self.instances
    @@instances
  end
end