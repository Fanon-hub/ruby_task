def display_menu
  puts "Please select the process you wish to perform"
  puts "1: Enter evaluation points and comments"
  puts "2: Check the results so far"
  puts "3: Stop"
end

def input_evaluation
  puts "Please enter a rating on a scale of 1 to 5"
  point = gets.to_i
  while true
    if point <= 0 || point > 5
      puts "Please enter on a scale of 1 to 5"
      point = gets.to_i
    else
      puts "Enter your comments"
      comment = gets.chomp
      post = "point：#{point}　comment：#{comment}"
      File.open("data.txt", "a") do |file|
        file.puts(post)
      end
      break
    end
  end
end

def display_results
  puts "Results to date"
  if File.exist?("data.txt")
    File.open("data.txt", "r") do |file|
      file.each_line do |line|
        puts line
      end
    end
  else
    puts "No data yet."
  end
end

while true
  display_menu
  num = gets.to_i
  case num
  when 1
    input_evaluation
  when 2
    display_results
  when 3
    puts "Termination."
    break
  else
    puts "Please enter 1 to 3"
  end
end