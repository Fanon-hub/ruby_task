require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include ItemManager
  include Ownable

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    # store items keyed by item number:
    # { number => { item: Item (one representative copy), quantity: n, seller: seller } }
    @cart_items = {}
  end

  # Return Item objects currently in the cart (never nil)
  def items
    @cart_items.values.flat_map { |entry| Array.new(entry[:quantity], entry[:item]) }
  end

  # Add either an Array (picked items from seller) or a single Item
  # items_or_item:
  #  - Array: result of Seller#pick_items(number, qty)
  #  - Item: a single Item
  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      template = items_array.first
      number = template.number
      seller = template.owner

      if @cart_items[number]
        @cart_items[number][:quantity] += quantity
      else
        # store a single representative copy (owner = cart) and keep seller reference
        rep = Item.new(template.number, template.name, template.price, 1, self)
        @cart_items[number] = { item: rep, quantity: quantity, seller: seller }
      end

    elsif items_or_item.is_a?(Item)
      item = items_or_item
      number = item.number
      seller = item.owner

      if @cart_items[number]
        @cart_items[number][:quantity] += quantity
      else
        rep = Item.new(item.number, item.name, item.price, 1, self)
        @cart_items[number] = { item: rep, quantity: quantity, seller: seller }
      end

    else
      # invalid input — ignore
      return
    end
  end

  # Total price for all items in the cart
  def total_amount
    @cart_items.values.sum { |e| e[:item].price * e[:quantity] }
  end

  # Pretty-print cart contents
  def items_list
    if @cart_items.empty?
      puts "Cart is empty."
      return
    end

    rows = @cart_items.values.map do |entry|
      item = entry[:item]
      [item.number, item.name, item.price, entry[:quantity]]
    end

    table = Terminal::Table.new(headings: ["ID", "Name", "Price", "Quantity"], rows: rows)
    puts table
  end

  # Checkout:
  #  - ensure buyer has enough funds
  #  - withdraw from buyer
  #  - deposit each seller their share
  #  - transfer ownership of purchased items to buyer
  #  - clear the cart
  def check_out
    total = total_amount
    unless owner.wallet.withdraw(total)
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # aggregate payouts per seller
    payouts = Hash.new(0)
    @cart_items.each_value do |entry|
      seller = entry[:seller]
      payouts[seller] += entry[:item].price * entry[:quantity]
    end

    # pay sellers
    payouts.each do |seller, amount|
      next unless seller && seller.respond_to?(:wallet)
      seller.wallet.deposit(amount)
    end

    # transfer ownership to buyer
    @cart_items.each_value do |entry|
      entry[:quantity].times do
        # create a new Item for the buyer (or reuse rep and set qty 1 repeatedly)
        purchased = Item.new(entry[:item].number, entry[:item].name, entry[:item].price, 1, owner)
        owner.add_item(purchased)
      end
    end

    # empty the cart
    @cart_items.clear

    puts "🎉 Checkout successful!"
  end
end