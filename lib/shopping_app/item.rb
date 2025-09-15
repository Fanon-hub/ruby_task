class Item
  attr_reader :number, :name, :price
  attr_accessor :owner

  @@instances = []

  def initialize(number, name, price, quantity, owner)
    @number = number
    @name = name
    @price = price
    @owner = owner
    quantity.times { @@instances << self.class.clone_item(self) }
  end

  def self.instances
    @@instances
  end

  # Helper to clone items (so each stock item is unique)
  def self.clone_item(item)
    new_item = allocate
    new_item.instance_variable_set(:@number, item.number)
    new_item.instance_variable_set(:@name, item.name)
    new_item.instance_variable_set(:@price, item.price)
    new_item.instance_variable_set(:@owner, item.owner)
    new_item
  end

  # 👇 Nice string representation
  def to_s
    "Item(##{@number}, #{@name}, price: #{@price}, owner: #{@owner.name})"
  end
end
