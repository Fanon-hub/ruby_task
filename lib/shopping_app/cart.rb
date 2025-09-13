require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include Ownable       # Provides @items management and add_item for ownership
  include ItemManager   # For items and pick_items

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @items = []  # Explicit init (Ownable may also set it)
    @item_sources = {}  # Track original owners
  end

  # Override to return internal @items
  def items
    @items
  end

  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      template = items_array.first
      seller = template.owner

      quantity.times do |i|
        stock_item = items_array[i] || template
        # Create copy for cart, set temp owner to self (Cart)
        cart_copy = Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        @items << cart_copy
        @item_sources[cart_copy.object_id] = seller
      end

    elsif items_or_item.is_a?(Item)
      item = items_or_item
      seller = item.owner

      quantity.times do
        # Create copy for cart
        cart_copy = Item.new(item.number, item.name, item.price, 1, self)
        @items << cart_copy
        @item_sources[cart_copy.object_id] = seller
      end

    else
      return
    end
  end

  def total_amount
    @items.sum { |i| i.price }
  end

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

  def check_out
    total = total_amount
    # Withdraw from cart owner; nil if insufficient
    withdrawn = owner.wallet.withdraw(total)
    unless withdrawn
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # Aggregate payments by original item owner (seller)
    payouts = Hash.new(0)
    @items.each do |cart_item|
      original_owner = @item_sources[cart_item.object_id]
      payouts[original_owner] += cart_item.price
    end

    # Transfer payments to item owners' wallets
    payouts.each do |item_owner, amount|
      next unless item_owner&.respond_to?(:wallet)
      item_owner.wallet.deposit(amount)
    end

    # Transfer ownership of existing cart items to cart owner
    @items.each do |cart_item|
      cart_item.owner = owner  # Update owner
      owner.add_item(cart_item)  # Store in buyer's @items (via Ownable)
    end

    # Empty cart contents
    @items.clear
    @item_sources.clear

    puts "🎉 Checkout successful!"
  end
end