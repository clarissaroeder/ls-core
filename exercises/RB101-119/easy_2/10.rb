# Write a method that takes a number as an argument. If the argument is a positive number, return the negative of that number. 
# If the number is 0 or negative, return the original number.

def negative(num)
  num > 0 ? -num : num
end


puts negative(5) == -5
puts negative(-3) == -3
puts negative(0) == 0    