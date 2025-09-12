require "terminal-table"
require_relative "user"   
require_relative "item"

class Seller < User
  attr_reader :items

  def initialize(name)
    super(name)               # Initializes User with name and wallet
    # Pre-populate stock items
    @items = [
      Item.new(1, "Apple", 100, 10, self),
      Item.new(2, "Banana", 50, 20, self),
      Item.new(3, "Orange", 80, 5, self)
    ]
  end

  def add_item(item)
    @items << item
    item.owner = self         # Makes sure the new items belongs to this seller
  end

  def items_list
    if @items.empty?
      puts "No items available."
    else
      rows = @items.map(&:label)
      table = Terminal::Table.new(
        headings: ["ID", "Name", "Price", "Quantity"],
        rows: rows
      )
      puts table
    end
  end

  def pick_items(id, quantity)
    found = @items.find { |i| i.id == id }
    return nil unless found && found.quantity >= quantity

    found.quantity -= quantity
    Array.new(quantity) { Item.new(found.id, found.name, found.price, 1, self) }
  end
end