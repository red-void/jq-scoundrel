import "./cards" as cards;
import "./messages" as messages;

# Gameplay actions handlers

# Run handler
# Moves all the 'room' cards to the end of the 'dungeon', fills the room one more time.
# Also restricts player to run again until the next room cleaning.
# Returns array of [updated_dungeon, updated_room, updated_state].
def run($dungeon; $room; $state; $room_size):
	messages::run_event
	| cards::move($room; $dungeon; $room_size) as [$empty_room, $full_dungeon]
	| cards::move($full_dungeon; $empty_room; $room_size) as [$upd_dungeon, $upd_room]
	| ($state | .healed = false | .ready_to_run = false) as $upd_state
	| [$upd_dungeon, $upd_room, $upd_state];

# Weapon pick up handler
# Returns updated player state (with the new weapon).
def pick_up($state; $weapon; $max_enemy_level):
	messages::pick_up_event($weapon)
	| ($state | .weapon = {"value": $weapon.value, "name": $weapon.name, "symbol": $weapon.symbol, "last_killed": $max_enemy_level});

# Potion drink handler
# Returns updated player state (healed or not).
def drink($state; $potion; $max_health):	
	if $state.healed then
		messages::drink_without_heal_event($potion) | $state
	else
		messages::drink_event($potion; ([$potion.value, $max_health - $state.health] | min))
		| ($state | .health = ([$state.health + $potion.value, $max_health] | min) | .healed = true)
	end;

# Armed fight handler
# Returns updated player state (with the worn out weapon and damaged health).
def fight_with_weapon($state; $monster):
	if $state.weapon.value >= $monster.value then
		messages::slaughter($monster)
		| ($state | .weapon.last_killed = $monster.value)
	else
		messages::fight_with_weapon($monster; $state.weapon)
		| ($state | .weapon.last_killed = $monster.value | .health = $state.health - ($monster.value - $state.weapon.value))
	end;

# Barehanded fight handler
# Returns updated player state (with damaged health).
def fight_barehanded($state; $monster):
	messages::fight_barehanded($monster)
	| ($state | .health = $state.health - $monster.value);

# Fight choose handler
def fight_choose($state; $monster):
	messages::fight_choose 
	| input as $input
	| if $input == 1 then fight_with_weapon($state; $monster)
	else fight_barehanded($state; $monster)
	end;

# General encounter handler
# Choose the proper handler depends on the chosen card.
# Returns array of [updated_dungeon, updated_room, updated_state].
def encounter($dungeon; $room; $state; $index; $max_health; $max_enemy_level):
	$room[$index] as $card |
	if $card.type == "Potion" then 
		drink($state; $card; $max_health) as $upd_state
		| cards::discard($room; $index) as $upd_room
		| [$dungeon, $upd_room, $upd_state]
	elif $card.type == "Monster" then
		(
		if $state.weapon.value == 0 then
			fight_barehanded($state; $card) as $upd_state
			| cards::discard($room; $index) as $upd_room
			| [$dungeon, $upd_room, $upd_state]
		elif $state.weapon.last_killed <= $card.value then
			messages::forced_barehanded_fight
			| fight_barehanded($state; $card) as $upd_state
			| cards::discard($room; $index) as $upd_room
			| [$dungeon, $upd_room, $upd_state]
		else
			fight_choose($state; $card) as $upd_state
			| cards::discard($room; $index) as $upd_room
			| [$dungeon, $upd_room, $upd_state]
		end
		)
	else 
		pick_up($state; $card; $max_enemy_level) as $upd_state
		| cards::discard($room; $index) as $upd_room
		| [$dungeon, $upd_room, $upd_state]
	end;

# Menu handler
# Executes interaction with the room object, runs handler or quits the game.
def handle_input($dungeon; $room; $state; $max_health; $room_size; $max_enemy_level; $input):
	if $input == 0 then halt	
	elif $input <= ($room | length) then
		encounter($dungeon; $room; $state; $input-1; $max_health; $max_enemy_level)
	elif $input == ($room_size + 1) and $state.ready_to_run and ($room | length) == $room_size and ($dungeon | length) > 0 then
		run($dungeon; $room; $state; $room_size)
	else
		messages::err_message($input)
		| [$dungeon, $room, $state]
	end;

# Fill the room with cards from the dungeon and make player to be able to run and be healed.
def enter_the_room($dungeon; $room; $state; $room_size):
	cards::move($dungeon; $room; $room_size - ($room | length)) as [$upd_dungeon, $upd_room]
	| ($state | .healed = false | .ready_to_run = true) as $upd_state
	| [$upd_dungeon, $upd_room, $upd_state];

# Game over handler
def game_over($dungeon; $room; $state; $full_deck; $max_health):
	cards::monster_score($full_deck) as $max_monster_score
	| ($max_monster_score - cards::monster_score($room) - cards::monster_score($dungeon)) as $current_monster_score
	| messages::game_over($current_monster_score + $state.health; $max_monster_score + $max_health)
	| halt;

# Game finished handler
def win($dungeon; $state; $full_deck; $max_health):
	(cards::monster_score($full_deck) + $max_health) as $max_score
	| (cards::monster_score($full_deck) + $state.health) as $score
	| messages::win($score; $max_score)
	| halt;

# Handle what happens after the encounter
# Returns array of updated ['dungeon', 'room', 'state'] or quits the game.
def handle_encounter_result($dungeon; $room; $state; $full_deck; $max_health; $room_size):
	if $state.health <= 0 then
		game_over($dungeon; $room; $state; $full_deck; $max_health)
	elif ($room | length) <= 1 and ($dungeon | length) > 0 then
		enter_the_room($dungeon; $room; $state; $room_size)
	elif ($room | length) == 0 and ($dungeon | length) == 0 then
		win($dungeon; $state; $full_deck; $max_health)
	else
		# Everything is fine, nothing to do
		[$dungeon, $room, $state]
	end;

