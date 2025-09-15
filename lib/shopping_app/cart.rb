# cart class 
require "terminal-table"
# require_relative "ownable"
require_relative "item_manager"
require_relative "item"  # For Item class access

class Cart
  # include Ownable
  include ItemManager

  attr_reader :owner

  def initialize(owner)
    @owner = owner
    @item_sources = {}  # { item.object_id => seller }
  end

  def add(items_or_item, quantity = 1)
    if items_or_item.is_a?(Array)
      items_array = items_or_item
      return if items_array.empty? || items_array.size < quantity

      seller = items_array.first.owner

      quantity.times do |i|
        stock_item = items_array[i]
        cart_copy = Item.new(stock_item.number, stock_item.name, stock_item.price, 1, self)
        @item_sources[cart_copy.object_id] = seller
      end
    elsif items_or_item.is_a?(Item)
      item = items_or_item
      seller = item.owner

      quantity.times do
        cart_copy = Item.new(item.number, item.name, item.price, 1, self)
        @item_sources[cart_copy.object_id] = seller
      end
    else
      return
    end
  end

  def total_amount
    items.sum { |i| i.price }
  end

  def items_list
    if items.empty?
      puts "Cart is empty."
      return
    end

    grouped = items.group_by(&:number)
    rows = grouped.map do |number, group|
      it = group.first
      [it.number, it.name, it.price, group.size]
    end

    table = Terminal::Table.new(headings: ["ID", "Name", "Price", "Quantity"], rows: rows)
    puts table
  end

  def check_out
    total = total_amount
    withdrawn = owner.wallet.withdraw(total)
    unless withdrawn
      puts "⚠️ Not enough balance to complete checkout."
      return
    end

    payouts = Hash.new(0)
    items.each do |item|
      seller = @item_sources[item.object_id]
      payouts[seller] += item.price if seller
    end

    payouts.each do |seller, amount|
      next unless seller.respond_to?(:wallet)
      seller.wallet.deposit(amount)
    end

    items.each do |item|
      item.owner = owner
    end

    @item_sources.clear

    puts "🎉 Checkout successful!"
  end
end