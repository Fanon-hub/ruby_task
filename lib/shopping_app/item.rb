require_relative "ownable"
class Item
  include Ownable

  attr_reader :name, :price
  attr_accessor :number, :quantity

  @@instances = []

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name
    @price = price
    @quantity = quantity
    self.owner = owner
    @@instances << self
  end

  # Add this method
  def id
    @number
  end

  def label
    { number: @number, name: @name, price: @price }
  end

  def self.instances
    @@instances
  end
end
