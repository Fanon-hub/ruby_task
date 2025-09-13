require_relative "item"

module ItemManager
  # Returns all Item objects for which `self` is the owner.
  # Uses Item.instances so this works for Seller, Customer, Cart, etc.
  def items
    Item.instances.select { |i| i.owner == self }
  end

  # Return an array of items matching product `number`, up to `quantity`.
  # Returns nil for invalid quantity or if not enough owned items are available.
  def pick_items(number, quantity)
    return nil if quantity <= 0
    owned_items = items.select { |i| i.number == number }
    return nil if owned_items.empty? || owned_items.size < quantity
    owned_items[0, quantity]
  end

  # NEW: Add multiples of an item with quantity management (handles edge cases like nil/invalid)
  def add_item_with_quantity(item, quantity)
    return nil unless item.is_a?(Item) && quantity.is_a?(Integer) && quantity.positive?
    quantity.times do
      # Duplicate to avoid modifying original
      dup_item = item.dup
      dup_item.owner = self
      Item.instances << dup_item  # Add to global instances
      add_item(dup_item)  # Use Ownable's add_item
    end
    items.last(quantity)  # Return the added ones
  end

  # Display grouped items in a table, grouped by product number (label), with quantities
  def items_list
    all_items = items
    return puts "No items." if all_items.empty?

    grouped = all_items.group_by(&:number)
    rows = grouped.map do |number, group|
      first_item = group.first
      [first_item.number, first_item.name, first_item.price, group.size]
    end

    table = Terminal::Table.new(headings: ["Item Number", "Item Name", "Amount", "Quantity"], rows: rows)
    puts table
  end
end