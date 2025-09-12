require_relative "item"
require "kosi"

# By including this module, you can manipulate your own Item instances.
module ItemManager

  def items
    Item.instances.select { |item| item.owner == self }
  end

  
  # Returns nil if quantity <= 0 or if requested number of items is not available
  def pick_items(number, quantity)
    return nil if quantity <= 0

    # Select items that match the given number and belong to self
    matching_items = items.select { |item| item.number == number }

    # Return nil if no items found or not enough items
    return nil if matching_items.empty? || matching_items.size < quantity

    matching_items[0, quantity]  # Return the first 'quantity' items
  end

  
  def items_list
    # Initialize Kosi table with headers
    kosi = Kosi::Table.new({ header: %w{Item\ Number Item\ Name Amount Quantity} })

    # Group owned items by label (name & price) and count quantities
    grouped_data = items
      .group_by { |item| item.label.merge(number: item.number) } # Groups by number, name, price
      .map do |label, group_items|
        [
          label[:number],
          label[:name],
          label[:price],
          group_items.size  # Quantity is count of grouped items
        ]
      end

    # Print the table
    print kosi.render(grouped_data)
  end
end
