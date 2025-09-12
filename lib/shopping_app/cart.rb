require "terminal-table"
require_relative "ownable"  # Load Ownable module
require_relative "item_manager"  # Load ItemManager module

class Cart
  include Ownable  # Include Ownable for @items and add_item
  include ItemManager  # Include ItemManager for items management

  attr_reader :owner  # Keep @owner as reader

  def initialize(owner)
    @owner = owner
    # @items is now handled by Ownable (array of Item instances)
    # Override ItemManager#items to manage cart-specific items
    @cart_items = {}  # Internal hash: { id => { item: Item, quantity: n } }
  end

  # Override ItemManager#items to return cart contents as Item instances
  def items
    @cart_items.values.flat_map do |entry|
      Array.new(entry[:quantity]) { entry[:item] }  # Expand to individual Item instances
    end
  end

  def add(item, quantity = 1)
    if @cart_items[item.id]
      @cart_items[item.id][:quantity] += quantity
    else
      @cart_items[item.id] = { item: item, quantity: quantity }
    end
    # Since items now uses @cart_items, no need to store in @items explicitly
  end

  def total_amount
    @cart_items.values.sum { |entry| entry[:item].price * entry[:quantity] }  # Total price of items in cart
  end

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

  def check_out
    total = total_amount
    if owner.wallet.balance >= total
      # Transfer purchase amount from cart owner to item owners
      @cart_items.each_value do |entry|
        # Deposit to the original item owner's wallet (seller)
        entry[:item].owner.wallet.deposit(entry[:item].price * entry[:quantity])
      end
      owner.wallet.withdraw(total)  # Deduct total from cart owner (customer)

      # Transfer ownership: Add all cart items to cart owner via Ownable#add_item
      items.each do |item|  # Uses overridden #items
        new_item = Item.new(
          item.id,
          item.name,
          item.price,
          1,  # Each transferred item has qty=1
          owner  # New owner: cart owner (customer)
        )
        owner.add_item(new_item)  # Transfer to cart owner's @items
      end

      @cart_items.clear  # Empty the cart contents
      @items.clear if @items  # Also clear Ownable @items if populated
      puts "🎉 Checkout successful!"
    else
      puts "⚠️ Not enough balance to complete checkout."
    end
  end
end