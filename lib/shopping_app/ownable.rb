
module Ownable
  attr_reader :items
  attr_accessor :owner 

  def initialize(*args)
    super  # Call parent initialize if needed
    @items ||= []  # Initialize empty array if not already set
  end

  def add_item(item)
    @items << item
  end
end