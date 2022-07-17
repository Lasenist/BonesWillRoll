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

enum SelectionWait {
	TAKE,
	FIGHTER_ATTACK,
	ROGUE_PLANT,
	ROGUE_STEAL
}
var current_selection_wait = null

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

var is_round_ending = false
func _end_round(delta):	
	if !is_round_ending :
		is_round_ending = true
		abilities_action_box.is_active = false
		
		end_round.is_active = true	
		
		_get_active_character().is_active = false
		current_active_adventurer += 1
		
		if current_active_adventurer >= character_turn_order.size():
			current_active_adventurer = 0
		
		yield(get_tree().create_timer(1), "timeout")
		end_round.is_active = false		
		current_state = GameState.START_ROUND_ONE
		is_round_ending = false
	
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
	
# --------------------------
# END OF SELECTION
# --------------------------
func _on_field_selection_made(selected_entities):
	
	match current_selection_wait :
		SelectionWait.TAKE :
			for entity in selected_entities :
				_get_active_character().add(entity)
				pass
		SelectionWait.FIGHTER_ATTACK :
			# The field removes them anyway, so do nothing			
			pass
		SelectionWait.ROGUE_PLANT :
			# the field removes, filled with runes in pre-fill stage below
			pass
	pass # Replace with function body.
	
func _on_field_pre_fill_field():
	match current_selection_wait:
		SelectionWait.ROGUE_PLANT:
			var rune_entity = FieldEntity.new()
			rune_entity.type = "rune"
			rune_entity.level = rogue.rune_level_just_spent
			field.fill_gaps_with_rune(rune_entity)
			pass
		
	pass # Replace with function body.
	
func _on_field_post_selection_made():
	match current_selection_wait :
		SelectionWait.TAKE :
			current_state = GameState.START_ROUND_TWO
		SelectionWait.FIGHTER_ATTACK :
			current_state = GameState.END_ROUND
		SelectionWait.ROGUE_PLANT :
			current_state = GameState.END_ROUND
		_:
			print("Selection Reason Not Found!!")
			assert(false)
	current_selection_wait = null
	

# --------------------------
# ROUND ONE
# --------------------------
func _on_take_action_box_regular_action_taken():
	current_selection_wait = SelectionWait.TAKE
	field.selection_length = 3
	field.is_selection_allowed = true

func _on_take_action_box_dice_rolled(result : int):
	field.selection_length = result
	field.is_selection_allowed = true

# --------------------------
# ROUND TWO
# --------------------------

# SWAP THREE
func _on_abilities_action_box_swap_three_pressed():
	field.selected_amount_to_reach = 3
	field.is_multi_select_allowed = true

# SWAP DICE
func _on_abilities_action_box_swap_dice_pressed(result : int):
	field.selected_amount_to_reach = result
	field.is_multi_select_allowed = true

func _on_field_post_swap_made():
	current_state = GameState.END_ROUND

# HEAL THREE
func _on_abilities_action_box_heal_three_pressed():
	_get_active_character().heal(3)

# HEAL DICE
func _on_abilities_action_box_heal_dice_pressed(result : int):
	_get_active_character().heal(result)

func _on_finished_healing():
	current_state = GameState.END_ROUND

# --------------------------
# FIGHTER - ATTACK
# --------------------------

func _on_fighter_attack_action_cut_three_pressed():
	current_selection_wait = SelectionWait.FIGHTER_ATTACK
	field.selection_length = 3
	field.is_selection_allowed = true

func _on_fighter_attack_action_cut_dice_pressed(result : int):
	current_selection_wait = SelectionWait.FIGHTER_ATTACK
	field.selection_length = result
	field.is_selection_allowed = true

# --------------------------
# FIGHTER - TAUNT
# --------------------------

func _on_fighter_taunt_action_taunt_three_pressed():
	_fighter_take_wounds_from(rogue, 3)
	_fighter_take_wounds_from(cleric, 3)
	current_state = GameState.END_ROUND	

func _on_fighter_taunt_action_taunt_dice_pressed(result : int):
	_fighter_take_wounds_from(rogue, result)
	_fighter_take_wounds_from(cleric, result)
	current_state = GameState.END_ROUND	
	pass # Replace with function body.
	
func _fighter_take_wounds_from(character, level):
	var wounds = character.get_wounds()
	var wounds_to_take = []
	for wound in wounds :
		if wound <= 3 :
			wounds_to_take.append(wound)
	
	for wound_to_take in wounds_to_take:
		character.heal(wound_to_take)
		var new_wound = FieldEntity.new()
		new_wound.type = "enemy"
		new_wound.level = wound_to_take - 1
		fighter.add(new_wound)
		pass
	pass
	
	pass # Replace with function body.


# --------------------------
# ROGUE - PLANT
# --------------------------
func _on_rogue_plant_action_plant_three_pressed():
	current_selection_wait = SelectionWait.ROGUE_PLANT
	field.is_selection_allowed = true
	field.selection_length = 3

func _on_rogue_plant_action_plant_dice_pressed(result : int):
	current_selection_wait = SelectionWait.ROGUE_PLANT
	field.is_selection_allowed = true
	field.selection_length = result


func _on_rogue_steal_action_steal_three_pressed():
	current_selection_wait = SelectionWait.ROGUE_STEAL
	field.is_multi_select_allowed = true
	field.selected_amount_to_reach = 3
