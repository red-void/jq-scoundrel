# Card primitives

# Move at most 'number' cards from 'source_deck' to 'destination_deck'
# Returns an array of two elements: [updated_source_deck; updated_destination_deck].
def move($source_deck; $destination_deck; $number):
	if ($source_deck | length) < $number then [[], $destination_deck + $source_deck]
	else $source_deck[:$number] as $added | [$source_deck[$number:], $destination_deck + $added]
	end;

# Discard a card number 'index' from 'deck'
# Returns a new deck — without the discarded card.
def discard($deck; $index):
	$deck[:$index] + $deck[$index+1:];

# Sums values of all monsters from the 'deck'
# Returns this sum.
def monster_score($deck):
	reduce $deck[] as $card (0; . + (if $card.type == "Monster" then $card.value else 0 end));

