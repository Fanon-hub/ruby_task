
module Ownable
  attr_reader :items
  # attr_accessor :owner 

  def items
    @items ||= []  # Initialize empty array if not already set
  end

  def add_item(item)
    @items ||= []
    @items << item
  end
end