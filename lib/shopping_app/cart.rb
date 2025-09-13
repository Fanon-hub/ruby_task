
# // filepath: [cart.rb](http://_vscodecontentref_/2)
require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include ItemManager   # provide pick_items, etc. if needed elsewhere
  include Ownable       # Ownable#items will be used for ownership semantics

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    # Store cart entries as an array of hashes:
    # { item: Item (owned temporarily by the cart), seller: original_seller }
    @items = []
  end

  # Return Item objects currently in the cart (never nil)
  def items
    @items.map { |entry| entry[:item] }
  end

  # Add either:
  # - an Array (result of seller.pick_items(number, qty)), plus quantity param
  # - a single Item and an optional quantity
  # We store copies in the cart (owner = self) and remember original seller for payouts.
  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      template = items_array.first
      seller = template.owner

      quantity.times do |i|
        stock_item = items_array[i] || template
        cart_copy = Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        @items << { item: cart_copy, seller: seller }
      end

    elsif items_or_item.is_a?(Item)
      item = items_or_item
      seller = item.owner
      quantity.times do
        cart_copy = Item.new(item.number, item.name, item.price, 1, self)
        @items << { item: cart_copy, seller: seller }
      end

    else
      # invalid input: ignore
      return
    end
  end

  # Total price for all items in the cart
  def total_amount
    items.sum { |i| i.price }
  end

  # Pretty-print cart contents
  def items_list
    if @items.empty?
      puts "Cart is empty."
      return
    end

    rows = @items.group_by { |e| e[:item].number }.map do |number, group|
      item = group.first[:item]
      [item.number, item.name, item.price, group.size]
    end

    table = Terminal::Table.new(headings: ["ID", "Name", "Price", "Quantity"], rows: rows)
    puts table
  end

  # Checkout: transfer money to sellers, withdraw from buyer, transfer ownership, clear cart
  def check_out
    total = total_amount
    if owner.wallet.balance < total
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # aggregate amounts per seller
    payouts = {}
    @items.each do |entry|
      seller = entry[:seller]
      payouts[seller] ||= 0
      payouts[seller] += entry[:item].price
    end

    # Pay sellers
    payouts.each do |seller, amount|
      if seller && seller.respond_to?(:wallet)
        seller.wallet.deposit(amount)
      end
    end

    # Withdraw total from buyer
    owner.wallet.withdraw(total)

    # Transfer ownership: make cart items belong to owner and add to owner's collection
    @items.each do |entry|
      item = entry[:item]
      item.owner = owner   # Item has accessor :owner
      owner.add_item(item) # Owner (customer) keeps track of owned items via Ownable#add_item
    end

    # Empty the cart
    @items.clear

    puts "🎉 Checkout successful!"
  end
end