# customer class inherits from user class
require_relative "user"
require_relative "cart"
require_relative "ownable"

class Customer < User
  attr_reader :cart
  include Ownable 

  def initialize(name)
    super(name)
    @cart = Cart.new(self)
  end
end