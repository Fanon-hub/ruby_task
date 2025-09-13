require_relative "ownable"

class Item
  include Ownable

  attr_reader :name, :price
  attr_accessor :number, :quantity, :owner  # Add :owner here for @owner support

  @@instances = []

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name
    @price = price
    @quantity = quantity
    self.owner = owner  # Now works with attr_accessor
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