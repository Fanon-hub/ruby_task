require_relative "ownable"

class Item
  include Ownable

  # Use attr_reader for name, price (no setters allowed)
  # number already has attr_reader, owner and quantity have attr_accessor
  attr_reader :number, :name, :price
  attr_accessor :owner, :quantity

  @@instances = []

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name           # Store in @name instance variable
    @price = price.to_i    # Store in @price instance variable  
    @quantity = quantity.to_i
    @owner = owner         # Store in @owner instance variable

    # Store in @@instances (each call creates one Item instance)
    @@instances << self
  end

  # Return the id/number
  def id
    @number
  end

  # Return a hash of { name: own name, price: own price }
  def label
    { name: name, price: price }  # Use attr_reader methods, not instance variables
  end

  def to_s
    "Item(##{@number}, #{@name}, price: #{@price}, owner: #{@owner&.name})"
  end

  # Return all instantiated Item objects (@@instances)
  def self.instances
    @@instances
  end
end