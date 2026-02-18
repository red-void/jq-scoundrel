# Converting game events to the text

# Returns string with a single menu item to interact with the room object.
# Output examples:
#   'Pick up M4A1 — Weapon (level 100)'
#   'Drink Mojito — Potion (level 50)'
#   'Fight with Dr. Octopus — Monster (level 25)'
def get_room_menu_item($card):
	if $card.type == "Weapon" then "Pick up "
	elif $card.type == "Monster" then "Fight with "
	else "Drink "
	end +
	"\($card.symbol) \($card.name) — \($card.type) (level \($card.value))\n";

# Returns string with a current weapon info.
def get_weapon_info($weapon):
	if $weapon.value == 0 then
		# Bare hands
		"\($weapon.symbol) \($weapon.name)\n" 
	else 
		"\($weapon.symbol) \($weapon.name) (\($weapon.value) damage), you may attack enemies of at most \($weapon.last_killed - 1) power with it.\n"
	end;

# Returns string with a menu of possible actions.
def get_menu($dungeon; $room; $state; $room_size):
	(reduce $room[] as $card ([0, ""]; [.[0] + 1, .[1] + (.[0] + 1 | tostring) + ". " + get_room_menu_item($card)])
	| .[1]) as $room_objects
	| (if ($state.ready_to_run and ($room | length) == $room_size and ($dungeon | length) > 0) then "\($room_size + 1). Run\n" else "" end) as $run_option
	| "What do you want to do?\n" +
	$room_objects +
	$run_option +
	"0. Quit game\n"; 

# Returns string with a current game info: health, weapon, exploring progress, etc.
def get_game_info($dungeon; $room; $state; $total_dungeon_length; $max_health):
	"Your health: \($state.health) / \($max_health)\n" +
	"Your weapon: \(get_weapon_info($state.weapon))" + 
	"You \(if $state.ready_to_run then "" else "don't " end)have enough endurance to run.\n" +
	"Potions will \(if $state.healed then "not " else "" end )have effect on you\n" +
	"Dungeon explored: \(($total_dungeon_length) - ($dungeon | length) - ($room | length)) / \($total_dungeon_length)\n"; 

# Prints current game info and actions menu.
def state_and_menu($dungeon; $room; $state; $total_dungeon_length; $max_health; $room_size):
	get_game_info($dungeon; $room; $state; $total_dungeon_length; $max_health) as $info
	| get_menu($dungeon; $room; $state; $room_size) as $menu
	| ($info + "\n" + $menu | stderr) as $stderr | "";

# Prints what happens when you run.
def run_event:
	"You run cowardly! Now you need to clean at least one room to be able to run one more time!\n" | stderr;

# Prints what happens when you pick up new weapon.
def pick_up_event($weapon):
	"You picked up a brand new weapon — \($weapon.symbol) \($weapon.name) (damage \($weapon.value)). You may attack any enemy with it!\n" | stderr;

# Prints what happens when you drink not the first potion in the room.
def drink_without_heal_event($potion):
	"You drink \($potion.symbol) \($potion.name) potion, but nothing happens...\n" | stderr;

# Prints what happens when you drink the first potion in the room.
def drink_event($potion; $heal):
	"You drink \($potion.symbol) \($potion.name) potion and it restores you \($heal) health!\n" | stderr;

# Prints the barehanded fight result.
def fight_barehanded($monster):
	"You attacked \($monster.symbol) \($monster.name) with your bare hands and got \($monster.value) damage!\n" | stderr;

# Prints the armed fight result.
def fight_with_weapon($monster; $weapon):
	"You attacked \($monster.symbol) \($monster.name) with your \($weapon.symbol) \($weapon.name) and got \($monster.value - $weapon.value) damage! Your weapon is worn out, now you can attack only monsters of power \($monster.value - 1) and less with it.\n" | stderr;

# Prints what happens when you can't use your weapon to fight with the monster.
def forced_barehanded_fight:
	"Your weapon is too worn out to fight with this monster.\n" | stderr;

# Prints a menu to choose fight with weapon using or not.
def fight_choose:
	"Do you want to fight with bare hands or using your weapon?\n1. Use weapon\n2. Fight barehanded\n" | stderr;

# Prints what happens when you kill monster without getting damage.
def slaughter($monster):
	"You slaughtered \($monster.symbol) \($monster.name) with your powerful weapon and got no damage! Your weapon is worn out and is able to attack only monsters of power \($monster.value - 1) and less.\n" | stderr;

# Prints the start message.
def greetings:
	"Welcome to Scoundrel v1.0!\n" | stderr;

# Prints the game over message.
def game_over($score; $max_score):
	"You're dead :(\nYour final score is \($score) / \($max_score)\n" | stderr;

# Prints the game finished message.
def win($score; $max_score):
	"Congratulations, you explored all the dungeon and survived!\nYour final score is \($score) / \($max_score)\n" | stderr;

# Prints the error message.
def err_message($input):
	"Bad input: \($input)\n" | stderr;

