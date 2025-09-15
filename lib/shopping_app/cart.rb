require "terminal-table"
require_relative "ownable"
require_relative "item_manager"
require_relative "item"

class Cart
  include ItemManager
  include Ownable

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @items = []  # Override ItemManager's items storage
    # map each cart item (object_id) to its original seller
    @item_sources = {}  # { item.object_id => seller }
  end

  # Override ItemManager#items to return our @items array
  def items
    @items
  end

  # Add either:
  #  - an Array (result of Seller#pick_items(number, qty)), OR
  #  - a single Item and a quantity
  #
  # For each unit added we create a cart-owned Item (owner = self)
  # and remember the original seller in @item_sources so checkout can pay them.
  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      seller = items_array.first.owner

      quantity.times do |i|
        stock_item = items_array[i] || items_array.first
        cart_copy = Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        @items << cart_copy  # Add to our @items array
        @item_sources[cart_copy.object_id] = seller
      end

    elsif items_or_item.is_a?(Item)
      item = items_or_item
      seller = item.owner

      quantity.times do
        cart_copy = Item.new(item.number, item.name, item.price, 1, self)
        @items << cart_copy  # Add to our @items array
        @item_sources[cart_copy.object_id] = seller
      end

    else
      # invalid input — ignore silently
      return
    end
  end

  # Return the total price of the Item objects stored in @items
  def total_amount
    @items.sum { |item| item.price }
  end

  # Pretty-print cart contents
  def items_list
    if @items.empty?
      puts "Cart is empty."
      return
    end

    grouped = @items.group_by(&:number)
    rows = grouped.map do |number, group|
      it = group.first
      [it.number, it.name, it.price, group.size]
    end

    table = Terminal::Table.new(headings: ["ID", "Name", "Price", "Quantity"], rows: rows)
    puts table
  end

  # Checkout: withdraw from buyer, pay each seller, transfer ownership, clear cart
  def check_out
    total = total_amount
    withdrawn = owner.wallet.withdraw(total)
    unless withdrawn
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # Calculate payments for each seller
    payouts = Hash.new(0)
    @items.each do |item|
      seller = @item_sources[item.object_id]
      payouts[seller] += item.price if seller
    end

    # Transfer the purchase amount from cart owner's wallet to item owner's wallet
    payouts.each do |seller, amount|
      next unless seller && seller.respond_to?(:wallet)
      seller.wallet.deposit(amount)
    end

    # Transfer ownership of all items in the cart to the cart owner
    @items.each do |item|
      item.owner = owner
      owner.add_item(item) if owner.respond_to?(:add_item)
    end

    # Empty the cart contents (Cart#items)
    @items.clear
    @item_sources.clear

    puts "🎉 Checkout successful!"
  end
end