require_relative "user"
require_relative "cart"
require_relative "ownable"

class Customer < User
  include Ownable
  attr_reader :cart

  def initialize(name)
    super(name)
    @cart = Cart.new(self)  # Cart belongs to this customer
  end
end
