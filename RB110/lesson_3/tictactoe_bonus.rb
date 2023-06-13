require 'pry'
require 'yaml'

MESSAGES = YAML.load_file('tictactoe_messages.yml')

# CONSTANTS
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                 [1, 4, 7], [2, 5, 8], [3, 6, 9],
                 [1, 5, 9], [3, 5, 7]]

# METHODS
# Formatting
def prompt(msg)
  puts "=> #{msg}"
end

def joinor(arr, delimiter=', ', word='or')
  case arr.size
  when 0 then ''
  when 1 then arr.first.to_s
  when 2 then arr.join(" #{word} ")
  else
    arr[-1] = "#{word} #{arr.last}"
    arr.join(delimiter)
  end
end

# rubocop: disable Metrics/AbcSize
def display_board(brd)
  puts ""
  puts "     |     |     "
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}  "
  puts "     |     |     "
  puts ""
end
# rubocop: enable Metrics/AbcSize

def display_scores(scores)
  scores = <<~SCORES
  => SCOREBOARD:
  => Player: #{scores[:player]}     Computer: #{scores[:computer]}

  SCORES
  puts scores
end

# Game flow
def wait
  print MESSAGES['continue']
  gets
end

def play_again?
  print MESSAGES['again']
  answer = gets.chomp
  answer.upcase.start_with?('Y')
end

# Game play
def who_first
  current_player = ''
  loop do
    print MESSAGES['first']
    answer = gets.chomp.upcase
    if answer == 'Y'
      current_player = 'Player'
      break
    elsif answer == 'N'
      current_player = 'Computer'
      break
    else
      prompt MESSAGES['invalid_first']
    end
  end
  current_player
end

def initialise_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def play_round(brd, scores, current_player)
  loop do
    system 'clear'
    display_scores(scores)
    place_piece!(brd, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(brd) || board_full?(brd)
  end

  get_round_result(brd, scores)
end

def play_rounds(current_player)
  system 'clear'
  scores = { player: 0, computer: 0 }
  loop do
    board = initialise_board
    play_round(board, scores, current_player)

    if scores[:player] == 5 || scores[:computer] == 5
      prompt "#{detect_winner(board)} is the GRAND winner of this game!"
      puts ''
      break
    else
      prompt MESSAGES['keep_playing']
      wait
    end
  end
end

# Placing pieces
def alternate_player(current_player)
  current_player == 'Player' ? 'Computer' : 'Player'
end

def place_piece!(brd, current_player)
  if current_player == 'Player'
    display_board(brd)
    place_user!(brd)
  else
    place_computer!(brd)
    display_board(brd)
  end
end

def place_user!(brd)
  square = 0
  loop do
    prompt MESSAGES['layout']
    print "=> Choose a square (#{joinor(empty_squares(brd))}): "
    square = gets.chomp.to_i
    if empty_squares(brd).include?(square)
      break
    else
      prompt MESSAGES['invalid_square']
    end
  end
  brd[square] = PLAYER_MARKER
end

# rubocop: disable Metrics/CyclomaticComplexity, Metrics/MethodLength
def place_computer!(brd)
  square = nil

  WINNING_LINES.each do |line|
    win_square = find_potential_win(line, brd)
    if win_square
      square = win_square
      break
    end
  end

  if !square
    WINNING_LINES.each do |line|
      threat_square = find_immediate_threat(line, brd)
      if threat_square
        square = threat_square
        break
      end
    end
  end

  if !square
    square = brd[5] == INITIAL_MARKER ? 5 : empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end
# rubocop: enable Metrics/CyclomaticComplexity, Metrics/MethodLength

def find_immediate_threat(line, brd)
  if brd.values_at(*line).count(PLAYER_MARKER) == 2
    brd.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

def find_potential_win(line, brd)
  if brd.values_at(*line).count(COMPUTER_MARKER) == 2
    brd.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

# Determining result of a round
def get_round_result(brd, scores)
  system 'clear'
  if someone_won?(brd)
    scores = update_scores(detect_winner(brd), scores)
    display_scores(scores)
    display_board(brd)
    prompt "#{detect_winner(brd)} won this round!"
  else
    display_scores(scores)
    display_board(brd)
    prompt MESSAGES['tie']
  end
  puts ''
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if line.all? { |square| brd[square] == PLAYER_MARKER }
      return 'Player'
    elsif line.all? { |square| brd[square] == COMPUTER_MARKER }
      return 'Computer'
    end
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def update_scores(string, scores)
  string == 'Player' ? scores[:player] += 1 : scores[:computer] += 1
  scores
end

# GAME: START
system 'clear'
prompt MESSAGES['welcome']
puts ''
current_player = who_first

loop do
  play_rounds(current_player)

  break unless play_again?
end

puts ''
prompt MESSAGES['bye']
