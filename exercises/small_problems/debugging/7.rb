=begin
We wrote a neutralize method that removes negative words from sentences. 
However, it fails to remove all of them. What exactly happens?

  #delete is a destructive method, causing the remaining elements in the array to move up one index,
  effectively skipping the next element. 

=end

def neutralize(sentence)
  words = sentence.split(' ')
  words.select do |word|
     !negative?(word)
  end.join(' ')
end

def negative?(word)
  [ 'dull',
    'boring',
    'annoying',
    'chaotic'
  ].include?(word)
end

puts neutralize('These dull boring cards are part of a chaotic board game.')
# Expected: These cards are part of a board game.
# Actual: These boring cards are part of a board game.