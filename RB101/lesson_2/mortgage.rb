# Refine user prompts
def prompt(message)
  print("=> #{message}")
end

# Validate input numbers
# Exception: false ensures non-convertibles don't raise an error but return nil
def integer?(num)
  Integer(num, exception: false) != nil
end

def float?(num)
  Float(num, exception: false) != nil
end

def number?(num)
  integer?(num) || float?(num)
end

# Greet user
prompt("Welcome to mortgage calculator!\n")
prompt("-------------------------------\n")
prompt("Please enter your name: ")

# Get name and validate
name = ''
loop do
  name = gets.chomp

  if name.empty?
    prompt("No input. Please enter a name: ")
  else
    break
  end
end

# Personalised message
print("\n")
prompt("Hi #{name}! Let's figure out your mortagage plan together.\n\n")

loop do
  # Ask for details and validate answers
  loan_amount = ''
  loop do
    prompt("Please enter your loan amount: $ ")
    loan_amount = gets.chomp

    if number?(loan_amount)
      break
    else
      prompt("Invalid input. Please enter a valid number.\n")
    end
  end

  apr = ''
  loop do
    prompt("Please enter the Annual Percentage Rate (APR) in %: ")
    apr = gets.chomp

    if number?(apr)
      break
    else
      prompt("Invalid input. Please enter your APR in %.\n")
    end
  end

  prompt("Please enter the intended loan duration in years and months.\n")
  loan_duration_y = ''
  loop do
    prompt("  Years: ")
    loan_duration_y = gets.chomp

    if integer?(loan_duration_y)
      break
    else
      prompt("Invalid input. Please enter an integer.\n")
    end
  end

  loan_duration_m = ''
  loop do
    prompt("  Months: ")
    loan_duration_m = gets.chomp

    if integer?(loan_duration_m)
      break
    else
      prompt("Invalid input. Please enter an integer.\n")
    end
  end

  # m = p * (j / (1 - (1 + j)**(-n)))
  # Calculate monthly interest rate
  monthly_interest = apr.to_f / 100 / 12

  # Calculate loan duration in months
  loan_duration = (loan_duration_y.to_i * 12) + loan_duration_m.to_i

  # Calculate monthly payment
  monthly_pay = loan_amount.to_f *
                (monthly_interest /
                (1 - (1 + monthly_interest)**(-loan_duration)))

  # Calculate total payment
  total = monthly_pay * loan_duration
  interest_total = total - loan_amount.to_f

  # Display result
  print("\n")
  prompt("Given the details you have provided, your results are:\n")
  prompt("  Payment every month: $#{format('%.2f', monthly_pay)}\n")
  prompt("  Total of #{loan_duration} payments: $#{format('%.2f', total)}\n")
  prompt("  Total interest: $#{format('%.2f', interest_total)}\n\n")

  # Ask for re-run
  prompt("Would you like to calculate another mortgage plan? (Y for yes) ")
  answer = gets.chomp
  print("\n")
  break unless answer.downcase.start_with?('y')
end

prompt("Thanks for using mortgage calculator!\n\n")
