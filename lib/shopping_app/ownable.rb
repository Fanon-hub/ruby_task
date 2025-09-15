
module Ownable
  attr_reader :owner

  # Assigns an Item's owner to this object. Does not create Item instances;
  # it simply sets the item's owner reference so ItemManager/Item.instances
  # will consider it owned by `self`.
  def add_item(item)
    item.owner = self if item.respond_to?(:owner=)
    item
  end
end

