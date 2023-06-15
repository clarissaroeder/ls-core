require 'YAML'

# CONSTANTS
MESSAGES = YAML.load_file('21_messages.yml')
GOAL = 21
MINIMUM_HIT = 17

# METHODS
# Formatting/ game flow
def prompt(msg)
  puts "=> #{msg}"
end

def joinand(hand, last_value='?')
  values = hand.map { |card| card[1] }
  case values.size
  when 2
    values[-1] = " and #{last_value}"
    values.join
  else
    values[-1] = "and #{last_value}"
    values.join(', ')
  end
end

def wait
  puts ''
  print MESSAGES['wait']
  gets
end

def play_again?
  prompt MESSAGES['again']
  answer = gets.chomp
  answer.downcase.start_with?('y')
end

# Results and score keeping
def total(hand)
  values = hand.map { |card| card[0] }
  total = values.sum

  values.select { |v| v == 11 }.count.times do
    total -= 10 if total > GOAL
  end

  total
end

def busted?(total)
  total > GOAL
end

def detect_result(p_total, d_total)
  if p_total > GOAL
    :player_busted
  elsif d_total > GOAL
    :dealer_busted
  elsif p_total > d_total
    :player
  elsif d_total > p_total
    :dealer
  else
    :tie
  end
end

def update_scores(scores, result)
  if result == :dealer_busted || result == :player
    scores[:player] += 1
  elsif result == :player_busted || result == :dealer
    scores[:dealer] += 1
  end
  scores
end

def game_over?(scores)
  scores[:player] == 5 || scores[:dealer] == 5
end

# Displaying hands, scores, results
def display_scores(scores)
  scores = <<~SCORES
  => SCOREBOARD:
  => Player: #{scores[:player]}     Dealer: #{scores[:dealer]}

  SCORES
  puts scores
end

def show_hands(player, dealer, p_total, d_total)
  if dealer.size == 2
    dealer_hand = joinand(dealer)
    prompt format(MESSAGES['dealer_hand'], hand: dealer_hand)
  else
    dealer_hand = joinand(dealer, dealer[-1][1])
    prompt format(MESSAGES['dealer_all'],
                  hand: dealer_hand, total: d_total)
  end

  player_hand = joinand(player, player[-1][1])
  prompt format(MESSAGES['player_hand'], hand: player_hand, total: p_total)
  puts ''
end

def compare_hands(player, dealer, p_total, d_total)
  prompt "======================"
  prompt "Dealer has #{joinand(dealer, dealer[-1][1])}, " \
         "for a total of #{d_total}."
  prompt "You have #{joinand(player, player[-1][1])}, " \
         "for a total of #{p_total}."
  prompt "======================"
  puts ''
end

def display_result(p_total, d_total)
  result = detect_result(p_total, d_total)

  case result
  when :player_busted
    prompt MESSAGES['player_bust']
  when :dealer_busted
    prompt MESSAGES['dealer_bust']
  when :player
    prompt MESSAGES['win']
  when :dealer
    prompt MESSAGES['lose']
  when :tie
    prompt MESSAGES['tie']
  end
end

def display_grand_result(scores)
  puts ''
  prompt scores[:player] == 5 ? MESSAGES['grand_win'] : MESSAGES['grand_lose']
  puts ''
end

# Game play
def initialise_deck
  values = {}
  (2..10).each { |v| values[v.to_s] = v }
  %w(Jack Queen King).each { |v| values[v] = 10 }
  values['Ace'] = 11

  # deck = { hearts: {"2": 2, ... "ace": ELEVEN}, diamonds: {"2": 2...}...}
  new_deck = {}
  %w(Heart Diamonds Clubs Spades).each { |suit| new_deck[suit] = values }

  new_deck
end

def initialise_hands(deck)
  # hand = [card, card]
  player = []
  dealer = []

  2.times do |_|
    card = deal_card(deck)
    player << card

    card = deal_card(deck)
    dealer << card
  end

  [player, dealer]
end

def deal_card(deck)
  suit = deck.keys.sample
  card_value = deck[suit].keys.sample
  # card = [numeric value, "value", "suit"]
  card = [deck[suit][card_value], card_value, suit]
  deck[suit].delete(card_value)
  card
end

def prompt_choice
  choice = ''
  loop do
    print MESSAGES['choice']
    choice = gets.chomp.downcase
    break if ['h', 's'].include?(choice)
    prompt MESSAGES['invalid_choice']
  end
  choice
end

def play_game
  scores = { player: 0, dealer: 0 }

  loop do
    wait
    system 'clear'
    deck = initialise_deck

    # initial deal
    player, dealer = initialise_hands(deck)
    player_total = total(player)
    dealer_total = total(dealer)

    # display status
    display_scores(scores)
    show_hands(player, dealer, player_total, dealer_total)

    # player turn
    loop do
      choice = prompt_choice

      if choice == 'h'
        system 'clear'
        player << deal_card(deck)
        display_scores(scores)
        prompt MESSAGES['hit']
        puts ''

        player_total = total(player)
        show_hands(player, dealer, player_total, dealer_total)
      end

      break if choice == 's' || busted?(player_total)
    end

    if busted?(player_total)
      compare_hands(player, dealer, player_total, dealer_total)
      display_result(player_total, dealer_total)
      update_scores(scores, detect_result(player_total, dealer_total))
      game_over?(scores) ? break : next
    else
      puts ''
      prompt format(MESSAGES['stay'], total: player_total)
      puts ''
    end

    # dealer turn
    loop do
      break if dealer_total >= MINIMUM_HIT
      dealer << deal_card(deck)
      prompt MESSAGES['dealer_hit']
      puts ''

      dealer_total = total(dealer)
      show_hands(player, dealer, player_total, dealer_total)

      break if busted?(dealer_total)
    end

    if busted?(dealer_total)
      compare_hands(player, dealer, player_total, dealer_total)
      display_result(player_total, dealer_total)
      update_scores(scores, detect_result(player_total, dealer_total))
      game_over?(scores) ? break : next
    else
      prompt format(MESSAGES['dealer_stay'], total: dealer_total)
      puts ''
    end

    compare_hands(player, dealer, player_total, dealer_total)
    display_result(player_total, dealer_total)
    update_scores(scores, detect_result(player_total, dealer_total))
    break if game_over?(scores)
  end

  display_grand_result(scores)
end

# MAIN GAME
system 'clear'
prompt MESSAGES['welcome']
prompt MESSAGES['how_to']

loop do
  play_game
  break unless play_again?
end

system 'clear'
prompt MESSAGES['bye']
puts ''

# Bonus 2: Why is the last use of "play_again?" in the staff solution different?
# The first two times we ask play_again?, if the answer is yes and it
# becomes true, we want to skip the remainder of the current loop and
# re-start the loop from the beginning. If the answer is no, we terminate
# the loop. That is why we use the ternary operator with next and break.
# The third time we use play_again? is at the last line of the loop, so there
# is nothing to skip of the remaining current iteration to re-start the loop
# from the beginning. That is why is is sufficient to simply break out of the
# loop when the answer is no.
