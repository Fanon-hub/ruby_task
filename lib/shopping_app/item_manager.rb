require_relative "item"
require "kosi"

module ItemManager
  # Return all items for which you are the owner
  # Returns a per-unit array of Item objects for which `self` is owner.
  # If an Item instance has quantity > 1, it will appear repeated `quantity` times.
  def items
    Item.instances
        .select { |item| item.owner == self }
        .flat_map { |item| Array.new([item.quantity, 0].max) { item } }
  end

  # Return items according to product number and quantity
  # Return an array of item-units matching product `number`, up to `quantity`.
  # Return nil when quantity invalid, product not owned, or not enough units owned.
  def pick_items(number, quantity)
    # Return nil if quantity is invalid (nil, zero, or negative)
    return nil if quantity.nil? || quantity <= 0

    # Get all item units that match the product number
    owned_units = items.select { |item| item.number == number }
    
    # Return nil if non-existent product number is specified (no items found)
    return nil if owned_units.empty?
    
    # Return nil if you specify a number greater than the number you own
    return nil if owned_units.size < quantity

    # Return the requested quantity of items
    owned_units[0, quantity]
  end

  # View a list of all items you own, categorized by label, and their quantities
  # Display grouped items in a table, grouped by product number/name/price, with quantities
  def items_list
    # Gather item instances owned by self (not the expanded per-unit array)
    owned_instances = Item.instances.select { |item| item.owner == self }
    
    if owned_instances.empty?
      puts "No items."
      return
    end

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