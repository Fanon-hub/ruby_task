require_relative "ownable"
require "terminal-table"

class Item
  include Ownable   

  @@instances = []  

  attr_reader :name, :price          
  attr_accessor :number, :quantity   

  def initialize(number, name, price, quantity = 1, owner = nil)
    @number = number
    @name = name
    @price = price
    @quantity = quantity
    self.owner = owner               
    @@instances << self              
  end

  # Returns the number/id
  def id
    @number
  end

  #  Return a hash with name and price
  def label
    { name: @name, price: @price }
  end

  #  Returns all instantiated Item objects
  def self.instances
    @@instances
  end
end
