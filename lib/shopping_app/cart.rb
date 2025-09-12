require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include Ownable   # Owner functionality
  include ItemManager  # Access #items if needed

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @cart_items = {}  # { item_id => { item: Item, quantity: n } }
  end

  # Return cart contents as an array of Item instances
  def items
    @cart_items.values.flat_map { |entry| Array.new(entry[:quantity], entry[:item]) }
  end

  # Add items to cart
  def add(item, quantity = 1)
    if @cart_items[item.id]
      @cart_items[item.id][:quantity] += quantity
    else
      @cart_items[item.id] = { item: item, quantity: quantity }
    end
  end

  # Total price of all items in the cart
  def total_amount
    @cart_items.values.sum { |entry| entry[:item].price * entry[:quantity] }
  end

  # Display cart contents
  def items_list
    if @cart_items.empty?
      puts "Cart is empty."
    else
      rows = @cart_items.values.map do |entry|
        i = entry[:item]
        [i.id, i.name, i.price, entry[:quantity]]
      end
      table = Terminal::Table.new(
        headings: ["ID", "Name", "Price", "Quantity"],
        rows: rows
      )
      puts table
    end
  end

  # Checkout: transfer money and ownership
  def check_out
    total = total_amount
    if owner.wallet.balance < total
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # Transfer money to item owners
    @cart_items.each_value do |entry|
      seller = entry[:item].owner
      seller.wallet.deposit(entry[:item].price * entry[:quantity])
    end

    # Deduct from cart owner
    owner.wallet.withdraw(total)

    # Transfer ownership
    items.each do |item|
      new_item = Item.new(item.id, item.name, item.price, 1, owner)
      owner.add_item(new_item)
    end

    # Clear the cart
    @cart_items.clear

    puts "🎉 Checkout successful!"
  end
end
