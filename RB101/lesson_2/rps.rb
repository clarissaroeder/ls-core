# CONSTANTS
VALID_CHOICES = %w(rock paper scissors lizard spock)

ABBREVIATIONS = %w(r p s l v)

WINNING_CONDITIONS = { 'scissors' => ['paper', 'lizard'],
                       'paper' => ['rock', 'spock'],
                       'rock' => ['lizard', 'scissors'],
                       'lizard' => ['spock', 'paper'],
                       'spock' => ['scissors', 'rock'] }

# METHODS
# Format user prompts
def prompt(message)
  puts("=> #{message}")
end

# Welcome message
def display_welcome
  welcome = <<~WELCOME
  => Welcome to Rock, Paper, Lizard, Spock!
  => You'll play against the computer. First to win 3 rounds wins the match!
  => -----------------------------------------------------------------------
  WELCOME
  puts welcome
end

# How-to-play message
def display_how_to_play
  rules = <<~RULES

  => Choose one: #{VALID_CHOICES.join(', ')}
  => To choose, type the word or its corresponding abbreviation:
  => rock(r); paper(p); scissors(s); lizard(l); spock(v)
  RULES
  puts rules
end

# Define winning conditions
# Bonus: include spock and lizard
def win?(first, second)
  losers = WINNING_CONDITIONS[first]
  losers.include?(second)
end

# Return round-result
def result_round(player, computer)
  if win?(player, computer)
    "You won!"
  elsif win?(computer, player)
    "You lost!"
  else
    "It's a tie!"
  end
end

# Display round result
def display_result_round(result, player, computer)
  result = <<~RESULT

  => You chose #{player}; computer chose #{computer}. #{result}

  RESULT
  puts result
end

# Display current score
def display_score(score1, score2)
  score = <<~SCORE
  => The current scores are: 
  => You: #{score1}    Computer: #{score2}

  SCORE
  puts score
end

# Display match results
def display_result_match(score1, score2)
  prompt("Final scores:")
  prompt("You: #{score1}    Computer: #{score2}")

  if score1 == 3
    prompt("Congratulations! You won the match.")
  else
    prompt("Too bad, the computer won the match this time!")
    prompt("----------------------------------------------")
  end

  puts ''
end

# GAME START
display_welcome

# Main game loop
loop do
  display_how_to_play

  player_score = 0
  computer_score = 0

  # Repeat until one reaches 3
  loop do
    # Get user choice
    choice = ''
    loop do
      choice = gets.chomp.downcase

      if VALID_CHOICES.include?(choice) || ABBREVIATIONS.include?(choice)
        break
      else
        prompt("That's not a valid choice.")
      end
    end

    # Transform user choice if they used abbreviation
    if choice.length == 1
      idx = ABBREVIATIONS.index(choice)
      choice = VALID_CHOICES[idx]
    end

    # Get computer choice
    computer_choice = VALID_CHOICES.sample

    # Get result of this round
    result = result_round(choice, computer_choice)

    # Update scores
    if result == "You won!"
      player_score += 1
    elsif result == "You lost!"
      computer_score += 1
    end

    # Display results
    display_result_round(result, choice, computer_choice)

    # Display current scores
    display_score(player_score, computer_score)

    if player_score == 3 || computer_score == 3
      break
    else
      prompt("Keep playing! This match is still going...")
    end
  end

  display_result_match(player_score, computer_score)

  prompt("Do you want to play again? Press 'Y' for yes.")
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

puts ''
prompt("Thank you for playing. Goodbye!")
