require_relative "shopping_app/seller"
require_relative "shopping_app/item"
require_relative "shopping_app/customer"
require "terminal-table"

# ----------------------------
# Setup seller and inventory
# ----------------------------
seller = Seller.new("DIC Store")

Item.new(1, "CPU", 40830, 10, seller)
Item.new(2, "Memory", 13880, 10, seller)
Item.new(3, "Motherboard", 28980, 10, seller)
Item.new(4, "Power Supply Unit", 8980, 10, seller)
Item.new(5, "PC Case", 8727, 10, seller)
Item.new(6, "3.5-inch HDD", 10980, 10, seller)
Item.new(7, "2.5-inch SSD", 13370, 10, seller)
Item.new(8, "M.2 SSD", 12980, 10, seller)
Item.new(9, "CPU Cooler", 13400, 10, seller)
Item.new(10, "Graphics Card", 23800, 10, seller)

# ----------------------------
# Ask customer details
# ----------------------------
puts "🤖 Please tell me your name"
customer = Customer.new(gets.chomp)

puts "🏧 Enter the amount to charge to your wallet"
customer.wallet.deposit(gets.chomp.to_i)

puts "🛍️ Shopping begins!"
end_shopping = false

# ----------------------------
# Shopping loop
# ----------------------------
while !end_shopping
  puts "\n📜 Product List"
  seller.items_list

  puts "\n⛏ Enter product ID"
  id = gets.to_i

  puts "⛏ Enter product quantity"
  quantity = gets.to_i

  items = seller.pick_items(id, quantity)
if items
  # pass the picked items array to the cart in one call (cart.add handles arrays)
  customer.cart.add(items, quantity)
  puts "✅ Added #{quantity} × #{items.first.name} to your cart."
else
  puts "⚠️ Item not found or insufficient stock."
end

  puts "\n🛒 Cart contents"
  customer.cart.items_list
  puts "🤑 Total amount: #{customer.cart.total_amount}"

  puts "\n😭 Do you want to finish shopping? (yes/no)"
  end_shopping = gets.chomp.downcase == "yes"
end

# ----------------------------
# Checkout
# ----------------------------
puts "\n💸 Do you want to confirm the purchase? (yes/no)"
customer.cart.check_out if gets.chomp.downcase == "yes"

# ----------------------------
# Final report
# ----------------------------
puts "\n୨୧┈┈┈┈┈┈┈┈┈┈┈┈┈Result┈┈┈┈┈┈┈┈┈┈┈┈┈୨୧"
puts "\n🛍️ Items owned by #{customer.name}"
customer.items_list

puts "\n👛 #{customer.name}'s wallet balance: #{customer.wallet.balance}"

puts "\n📦 #{seller.name}'s stock status"
seller.items_list

puts "\n👛 #{seller.name}'s wallet balance: #{seller.wallet.balance}"

puts "\n🛒 Cart contents"
customer.cart.items_list
puts "🌚 Total amount: #{customer.cart.total_amount}"

puts "\n🎉 End"
