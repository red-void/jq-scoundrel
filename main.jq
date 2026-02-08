import "./random" as random;
import "./messages" as messages;
import "./game" as game;

def init:
	messages::greetings
	| $data[0]["cards"] as $full_deck
	| random::fisher_yates_shuffle($full_deck; $data[0]["rng_linear_a"]; $data[0]["rng_linear_c"]; $data[0]["rng_linear_m"]) as $dungeon
	| [] as $room
	| $data[0]["player_state"] as $state
	| $data[0]["player_state"]["health"] as $max_health
	| $data[0]["room_size"] as $room_size
	| game::handle_encounter_result($dungeon; $room; $state; $full_deck; $max_health; $room_size);

def turn:
	. as [$dungeon, $room, $state]
	| $data[0]["cards"] as $full_deck
	| $data[0]["room_size"] as $room_size
	| $data[0]["player_state"]["health"] as $max_health
	| $data[0]["player_state"]["weapon"]["last_killed"] as $max_enemy_level
	| messages::state_and_menu($dungeon; $room; $state; $full_deck | length; $max_health; $room_size) 
	| input as $input
	| game::handle_input($dungeon; $room; $state; $max_health; $room_size; $max_enemy_level; $input) as [$upd_dungeon, $upd_room, $upd_state]
	| game::handle_encounter_result($upd_dungeon; $upd_room; $upd_state; $full_deck; $max_health; $room_size);	


init | while (true; . | turn) | ""
