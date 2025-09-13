require "terminal-table"
require_relative "ownable"
require_relative "item_manager"

class Cart
  include Ownable
  include ItemManager

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @cart_items = {}  # { number => { item: Item, quantity: n, seller: Seller } }
  end

  # Override for cart contents
  def items
    @cart_items.values.flat_map { |entry| Array.new(entry[:quantity], entry[:item]) }
  end

  # Accept either an Array (from pick_items) or a single Item
  def add(items_or_array, quantity = 1)
    if items_or_array.is_a?(Array)
      items_array = items_or_array
      return if items_array.empty? || items_array.size < quantity

      template_item = items_array.first
      number = template_item.number
      seller = template_item.owner

      if @cart_items[number]
        @cart_items[number][:quantity] += quantity
      else
        cart_copies = items_array[0, quantity].map do |stock_item|
          Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        end
        @cart_items[number] = { item: cart_copies.first, quantity: quantity, seller: seller }
      end

    elsif items_or_array.is_a?(Item)
      item = items_or_array
      number = item.number
      seller = item.owner

      if @cart_items[number]
        @cart_items[number][:quantity] += quantity
      else
        @cart_items[number] = {
          item: Item.new(item.number, item.name, item.price, 1, self),
          quantity: quantity,
          seller: seller
        }
      end

    else
      # invalid input; ignore
      return
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
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    # Pay each seller the amount for their items (if we stored seller at add time)
    @cart_items.each_value do |entry|
      seller = entry[:seller]
      if seller && seller.respond_to?(:wallet)
        seller.wallet.deposit(entry[:item].price * entry[:quantity])
      end
    end

    owner.wallet.withdraw(total)

    # Transfer ownership to customer
    items.each do |item|
      new_item = Item.new(item.number, item.name, item.price, 1, owner)
      owner.add_item(new_item)
    end

    @cart_items.clear
    puts "🎉 Checkout successful!"
  end
end