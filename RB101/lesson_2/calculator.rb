# ask the user for two numbers
# ask the user for an operation to perform
# perform the operation on the two numbers
# output the result

Kernel.puts("Welcome to Calculator!")

Kernel.puts("Put in a number:")
number_1 = Kernel.gets().chomp()

Kernel.puts("Put in another number:")
number_2 = Kernel.gets().chomp()

Kernel.puts("What operation do you want to perform? 1) add 2) subtract 3) multiply 4) divide")
operator = Kernel.gets().chomp()



if operator == '1' 
  result = number_1.to_i() + number_2.to_i()
elsif operator == '2'
  result = number_1.to_i() - number_2.to_i()
elsif operator == '3'
  result = number_1.to_i() * number_2.to_i()
else
  result = number_1.to_f() / number_2.to_f()
end

Kernel.puts("The result is #{result}!")
  