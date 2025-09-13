require_relative "ownable"

class Wallet
  include Ownable

  attr_reader :balance

  def initialize(owner, initial_balance = 0)
    @owner = owner
    @balance = initial_balance.to_f  # Use Float for decimals if needed
  end

  def deposit(amount)
    return nil unless amount.is_a?(Numeric) && amount >= 0
    @balance += amount
    @balance
  end

  def withdraw(amount)
    return nil unless amount.is_a?(Numeric) && amount >= 0 && amount <= @balance
    @balance -= amount
    amount
  end
end