# Refer to the text at [https://diver.diveintocode.jp/curriculums/2360] if you want to check the role of the module.
require "kosi"
require_relative "item"

# By including this module, you can manipulate your own Item instances.
module ItemManager
  def items # Returns all Item instances that you own (i.e., for which you are the owner).
    Item.instances.select { |item| item.owner == self }
  end

  def pick_items(number, quantity) # Returns the specified quantity of your own Item instances corresponding to the number.
    return nil if quantity <= 0

    matching_items = items.select { |item| item.number == number }
    return nil if matching_items.empty? || matching_items.size < quantity

    matching_items[0, quantity]  # Return the first quantity items
  end

  def items_list # Outputs the inventory status of your owned Item instances in a table format with columns ["Item Number", "Item Name", "Amount", "Quantity"].
    kosi = Kosi::Table.new({ header: %w{Item\ Number Item\ Name Amount Quantity} }) # Specify the URL of "kosi" in the Gemfile
    print kosi.render(
      items
        .group_by { |item| item.label }  # Group by label hash
        .map do |label, group_items|
          [
            label[:number],
            label[:name],
            label[:price],
            group_items.size  # Quantity as count of instances
          ]
        end
    )
  end
end