require "terminal-table"  # If not already there

class Item
  include Ownable

  @@instances = []  # Class variable: array to store all instantiated Item objects

  attr_reader :name, :price  # Read-only: no #name= or #price= setters

  attr_accessor :number, :quantity  # Keep these as writable

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name
    @price = price
    @quantity = quantity
    self.owner = owner
    @@instances << self  # Store this instance in @@instances
  end

  def id
    @number
  end

  def label
    { name: @name, price: @price }  # Returns hash { name: own name, price: own price }
  end

  def self.instances
    @@instances  # Returns the array of all instantiated Item objects
  end
end