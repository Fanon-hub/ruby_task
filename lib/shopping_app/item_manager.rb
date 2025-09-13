require_relative "item"
require "kosi"

module ItemManager
  # Return all items owned by this owner
  def items
    Item.instances.select { |item| item.owner == self }
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
    return puts "No items." if items.empty?

    grouped = items.group_by { |i| i.label.merge(number: i.number) }
    rows = grouped.map do |label, group|
      [label[:number], label[:name], label[:price], group.size]
    end

    table = Kosi::Table.new(header: %w{Item\ Number Item\ Name Amount Quantity})
    print table.render(rows)
  end
end
