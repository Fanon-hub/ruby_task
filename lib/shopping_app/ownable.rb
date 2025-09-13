
module Ownable
  attr_accessor :owner

  def add_item(item)
    @items ||= []
    @items << item
    item.owner = self if item.respond_to?(:owner=)
  end

  def items
    @items ||= []
  end
end