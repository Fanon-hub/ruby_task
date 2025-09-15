# wallet class
# require_relative "ownable"

class Wallet
  # include Ownable

  attr_reader :balance

  def initialize(owner)
    @owner = owner
    @balance = 0
  end

  def deposit(amount)
    @balance += amount.to_i
  end

  def withdraw(amount)
    amount = amount.to_i
    if @balance >= amount
      @balance -= amount
      amount
    else
      nil
    end
  end
end