require "terminal-table"
require_relative "user"
require_relative "item_manager"
require_relative "wallet"
require_relative "item"
require_relative "ownable"

class Seller < User
  include Ownable
  attr_reader :name, :wallet

  def initialize(name)
    super(name)                # call User#initialize to set name and wallet
    @items = []
    # Pre-populate stock items
    add_item(Item.new(1, "CPU", 40830, 10, self))
    add_item(Item.new(2, "Memory", 13880, 10, self))
    add_item(Item.new(3, "Motherboard", 28980, 10, self))
    add_item(Item.new(4, "Power Supply Unit", 8980, 10, self))
    add_item(Item.new(5, "PC Case", 8727, 10, self))
    add_item(Item.new(6, "3.5-inch HDD", 10980, 10, self))
    add_item(Item.new(7, "2.5-inch SSD", 13370, 10, self))
    add_item(Item.new(8, "M.2 SSD", 12980, 10, self))
    add_item(Item.new(9, "CPU Cooler", 13400, 10, self))
    add_item(Item.new(10, "Graphics Card", 23800, 10, self))
  end

  def items_list
    if items.empty?
      puts "No items available."
    else
      rows = items.map do |i|
        [i.id, i.name, i.price, i.quantity]
      end
      table = Terminal::Table.new(
        headings: ["ID", "Name", "Price", "Quantity"],
        rows: rows
      )
      puts table
    end
  end

  # def add_item(item)
  #   @items << item
  #   item.owner = self         # Makes sure the new items belongs to this seller
  # end

  def pick_items(number, quantity)
    picked = items.find { |i| i.number == number }
    return [] unless picked && picked.quantity >= quantity
    picked.quantity -= quantity
    picked.quantity = [picked.quantity, 0].max
    [picked]
  end
end