require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include Ownable       # keep Ownable for @items/ownership convenience
  include ItemManager   # ItemManager#items will be used as the canonical items list

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    # array of Item objects owned temporarily by the cart (owner = self)
    @items = []
    # mapping to remember original seller for each cart item
    @item_sources = {} # { cart_item.object_id => seller }
  end

  # For convenience tests may inspect @items directly; ItemManager#items uses Item.instances
  # and will pick up items whose owner == self (cart), since we create cart copies with owner = self.
  # Add picks either an Array (seller.pick_items) or a single Item.
  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      template = items_array.first
      seller = template.owner

      quantity.times do |i|
        stock_item = items_array[i] || template
        cart_copy = Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        @items << cart_copy
        @item_sources[cart_copy.object_id] = seller
      end

    elsif items_or_item.is_a?(Item)
      item = items_or_item
      seller = item.owner

      quantity.times do
        cart_copy = Item.new(item.number, item.name, item.price, 1, self)
        @items << cart_copy
        @item_sources[cart_copy.object_id] = seller
      end

    else
      # invalid input; ignore
      return
    end
  end

  # total price for all items currently in the cart
  def total_amount
    @items.sum { |i| i.price }
  end

  # pretty-print cart contents
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

  # Checkout:
  #  - ensure buyer has enough balance; withdraw first
  #  - pay each seller their aggregated amount
  #  - transfer ownership to buyer (create owned items for buyer)
  #  - clear the cart
  def check_out
    total = total_amount
    # withdraw returns amount on success, nil otherwise (per your Wallet implementation)
    unless owner.wallet.withdraw(total)
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # aggregate payouts per seller
    payouts = Hash.new(0)
    @items.each do |cart_item|
      seller = @item_sources[cart_item.object_id]
      payouts[seller] += cart_item.price
    end

    # pay sellers
    payouts.each do |seller, amount|
      next unless seller && seller.respond_to?(:wallet)
      seller.wallet.deposit(amount)
    end

    # transfer ownership to buyer: create new Item instances owned by buyer
    @items.each do |cart_item|
      purchased = Item.new(cart_item.number, cart_item.name, cart_item.price, 1, owner)
      owner.add_item(purchased)
    end

    # clear internal state and helper mapping
    @items.clear
    @item_sources.clear

    puts "🎉 Checkout successful!"
  end
end