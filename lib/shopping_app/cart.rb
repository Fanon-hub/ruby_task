require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include Ownable
  include ItemManager

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @cart_items = {}  # { item_id => { item: Item, quantity: n } }
  end

  def items
    @cart_items.values.flat_map { |entry| Array.new(entry[:quantity], entry[:item]) }
  end

  def add(item, quantity = 1)
    if @cart_items[item.number]
      @cart_items[item.number][:quantity] += quantity
    else
      @cart_items[item.number] = { item: item, quantity: quantity }
    end
  end

  def total_amount
    @cart_items.values.sum { |e| e[:item].price * e[:quantity] }
  end

  def items_list
    if @cart_items.empty?
      puts "Cart is empty."
    else
      rows = @cart_items.values.map { |e| [e[:item].number, e[:item].name, e[:item].price, e[:quantity]] }
      table = Terminal::Table.new(headings: ["ID", "Name", "Price", "Quantity"], rows: rows)
      puts table
    end
  end

  def check_out
    total = total_amount
    if owner.wallet.balance < total
      puts "⚠️ Not enough balance"
      return
    end

    # Transfer money
    @cart_items.each_value do |entry|
      entry[:item].owner.wallet.deposit(entry[:item].price * entry[:quantity])
    end
    owner.wallet.withdraw(total)

    # Transfer ownership
    items.each do |item|
      new_item = Item.new(item.number, item.name, item.price, 1, owner)
      owner.add_item(new_item)
    end

    @cart_items.clear
    puts "🎉 Checkout complete!"
  end
end
