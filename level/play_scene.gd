extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum GameState {
	START_ROUND_ONE
	ROUND_ONE,
	START_ROUND_TWO
	ROUND_TWO,
	END_ROUND
}
var current_state = GameState.START_ROUND_ONE

onready var fighter = $fighter
onready var rogue = $rogue
onready var cleric = $cleric
onready var current_active_adventurer = 0
onready var character_turn_order = [fighter, rogue, cleric]


onready var take_action_box = $take_action_box
onready var abilities_action_box = $abilities_action_box
onready var end_round = $end_round

onready var field = $Control/field

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_active_character():
	return character_turn_order[current_active_adventurer]
	pass

func _start_round_one(delta):
	abilities_action_box.is_active = false
	
	_get_active_character().is_active = true
	take_action_box.is_active = true
	
	current_state = GameState.ROUND_ONE
	return

func _start_round_two(delta):
	take_action_box.is_active = false
	
	abilities_action_box.is_active = true
	
	current_state = GameState.ROUND_TWO
	return

func _end_round(delta):	
	abilities_action_box.is_active = false
	
	end_round.is_active = true	
	
	_get_active_character().is_active = false
	current_active_adventurer += 1
	
	if current_active_adventurer >= character_turn_order.size():
		current_active_adventurer = 0
	
	yield(get_tree().create_timer(1), "timeout")
	end_round.is_active = false
	
	current_state = GameState.START_ROUND_ONE
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match current_state:
		GameState.START_ROUND_ONE:
			_start_round_one(delta)
			pass
		GameState.START_ROUND_TWO:
			_start_round_two(delta)
		GameState.END_ROUND:
			_end_round(delta)
	pass


func _on_take_action_box_regular_action_taken():
	field.selection_length = 3
	field.is_selection_allowed = true
	pass # Replace with function body.

func _on_take_action_box_dice_rolled(result : int):
	field.selection_length = result
	field.is_selection_allowed = true
	pass # Replace with function body.

func _on_field_selection_made(selected_entities):
	for entity in selected_entities :
		_get_active_character().add(entity)
		pass
	pass # Replace with function body.


func _on_field_post_selection_made():
	current_state = GameState.START_ROUND_TWO
	pass # Replace with function body.


func _on_abilities_action_box_swap_three_pressed():
	field.selected_amount_to_reach = 3
	field.is_multi_select_allowed = true
	pass # Replace with function body.

func _on_abilities_action_box_swap_dice_pressed(result : int):
	field.selected_amount_to_reach = result
	field.is_multi_select_allowed = true
	pass # Replace with function body.

func _on_abilities_action_box_heal_three_pressed():
	_get_active_character().heal(3)
	pass # Replace with function body.

func _on_abilities_action_box_heal_dice_pressed(result : int):
	_get_active_character().heal(result)
	pass # Replace with function body.

func _on_field_post_swap_made():
	current_state = GameState.END_ROUND
	pass # Replace with function body.


func _on_finished_healing():
	current_state = GameState.END_ROUND
	pass # Replace with function body.



