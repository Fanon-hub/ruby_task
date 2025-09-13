# customer class inherits from user class
require_relative "user"
require_relative "cart"

class Customer < User
  attr_reader :cart

  def initialize(name)
    super(name)
    @cart = Cart.new(self)
  end
end