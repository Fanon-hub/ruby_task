require_relative "item"
require "kosi"

module ItemManager
  # Return a per-unit array of Item objects for which `self` is owner.
  # If an Item instance has quantity > 1, it will appear repeated `quantity` times.
  def items
    Item.instances
        .select { |i| i.owner == self }
        .flat_map { |it| Array.new([it.quantity, 0].max) { it } }
  end

  # Return an array of item-units matching product `number`, up to `quantity`.
  # Return nil when quantity invalid, product not owned, or not enough units owned.
  def pick_items(number, quantity)
    return nil if quantity.nil? || quantity <= 0

    owned_units = items.select { |i| i.number == number }
    return nil if owned_units.empty? || owned_units.size < quantity

    owned_units[0, quantity]
  end

  # Display grouped items in a table, grouped by product number/name/price, with quantities
  def items_list
    # Gather item instances owned by self
    owned_instances = Item.instances.select { |i| i.owner == self }
    return puts "No items." if owned_instances.empty?

    # Group by product number and sum quantities correctly
    grouped = owned_instances.group_by(&:number)
    rows = grouped.map do |number, group|
      first_item = group.first
      total_qty = group.sum(&:quantity)
      [first_item.number, first_item.name, first_item.price, total_qty]
    end

    table = Kosi::Table.new(header: %w{Item\ Number Item\ Name Item\ Price Quantity})
    print table.render(rows)
  end
end