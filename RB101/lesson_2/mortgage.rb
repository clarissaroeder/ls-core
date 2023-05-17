require 'yaml'

MESSAGES = YAML.load_file('mortgage_messages.yml')

# Format user prompts
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

# Validate that input is non-0
def non_zero?(num)
  Integer(num) > 0 || Float(num) > 0
end

# Validate non-negative
def negative?(num)
  Integer(num) >= 0 || Float(num) >= 0
end

# Calculate monthly payments
def calculate_monthly_pay(loan_amount, monthly_interest, loan_duration)
  loan_amount.to_f * (monthly_interest /
  (1 - (1 + monthly_interest)**(-loan_duration)))
end

# Greet user
prompt(MESSAGES['welcome'])
prompt(MESSAGES['div'])
prompt(MESSAGES['name_prompt'])

# Get name and validate
name = ''
loop do
  name = gets.chomp

  if name.empty?
    prompt(MESSAGES['invalid_name'])
  else
    break
  end
end

# Personalised message
print("\n")
prompt(format(MESSAGES['greet'], name: name))

loop do
  # Ask for details and validate answers
  # Loan amount
  loan_amount = ''
  loop do
    prompt(MESSAGES['loan_amount_prompt'])
    loan_amount = gets.chomp

    if number?(loan_amount) && non_zero?(loan_amount)
      break
    else
      prompt(MESSAGES['invalid_amount'])
    end
  end

  # APR
  apr = ''
  loop do
    prompt(MESSAGES['apr_prompt'])
    apr = gets.chomp

    if number?(apr) && negative?(apr)
      break
    else
      prompt(MESSAGES['invalid_apr'])
    end
  end

  # Loan duration
  prompt(MESSAGES['duration_prompt'])
  loan_years = ''
  loan_months = ''
  loop do
    loop do
      prompt(MESSAGES['years'])
      loan_years = gets.chomp

      if integer?(loan_years) && negative?(loan_years)
        break
      else
        prompt(MESSAGES['invalid'])
      end
    end

    loop do
      prompt(MESSAGES['months'])
      loan_months = gets.chomp

      if integer?(loan_months) && negative?(loan_months)
        break
      else
        prompt(MESSAGES['invalid'])
      end
    end

    if non_zero?(loan_years) || non_zero?(loan_months)
      break
    else
      prompt(MESSAGES['invalid_duration'])
    end
  end

  # Calculate monthly interest rate
  monthly_interest = apr.to_f / 100 / 12

  # Calculate loan duration in months
  loan_duration = (loan_years.to_i * 12) + loan_months.to_i

  # Calculate monthly payment
  monthly_pay =
    calculate_monthly_pay(loan_amount, monthly_interest, loan_duration)

  # Calculate total payment
  total = monthly_pay * loan_duration
  interest_total = total - loan_amount.to_f

  # Display result
  print("\n")
  prompt(MESSAGES['results'])
  prompt("  Payment every month: $#{format('%.2f', monthly_pay)}\n")
  prompt("  Total of #{loan_duration} payments: $#{format('%.2f', total)}\n")
  prompt("  Total interest: $#{format('%.2f', interest_total)}\n\n")

  # Ask for re-run
  prompt(MESSAGES['again'])
  answer = gets.chomp
  print("\n")
  break unless answer.downcase.start_with?('y')
end

prompt(MESSAGES['thanks'])
