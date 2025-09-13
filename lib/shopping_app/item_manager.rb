require_relative "item"
require "kosi"

module ItemManager
  # Return all items owned by this owner
  def items
    Array(@cart_items&.values).flat_map { |entry| Array.new(entry[:quantity], entry[:item]) }
  end

  # Return items of given number and quantity
  def pick_items(number, quantity)
    return nil if quantity <= 0
    owned_items = items.select { |i| i.number == number }
    return nil if owned_items.empty? || owned_items.size < quantity
    owned_items[0, quantity]
  end

  # Display grouped items in a table
  def items_list
    all_items = items || []
    return puts "No items." if all_items.empty?

    grouped = all_items.group_by(&:number)
    rows = grouped.map do |number, group|
      first_item = group.first
      [first_item.number, first_item.name, first_item.price, group.size]
    end

    table = Kosi::Table.new(header: %w{Item\ Number Item\ Name Amount Quantity})
    print table.render(rows)
  end
end