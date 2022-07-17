extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum GameState {
	START_ROUND_ONE
	ROUND_ONE,
	START_ROUND_TWO
	ROUND_TWO,
	END_ROUND_TWO,
	END_ROUND,
	DEAD,
	WIN
}
var current_state = GameState.START_ROUND_ONE

enum SelectionWait {
	TAKE,
	SWAP,
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
	$AudioStreamPlayer.play()
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
	
	for round_two_node in get_tree().get_nodes_in_group("round_two"):
		round_two_node.is_active = true
	
	current_state = GameState.ROUND_TWO
	return

var ert_done = false
func _end_round_two(delta):
	if !ert_done :
		for round_two_node in get_tree().get_nodes_in_group("round_two"):
			round_two_node.is_active = false
		ert_done = true	

var is_round_ending = false
func _end_round(delta):	
	if !is_round_ending :
		is_round_ending = true
		for round_two_node in get_tree().get_nodes_in_group("round_two"):
			round_two_node.is_active = false
		
		end_round.is_active = true	
		
		var runes_needed = 9 * 3
		var rune_count = 0
		var dead_characters = 0
		for character in character_turn_order:
			rune_count += character.get_total_rune_count()		
			dead_characters += 1 if character.is_dead else 0
		
		if dead_characters == character_turn_order.size():
			current_state = GameState.DEAD
			$dead/active_bg.visible = true
		elif rune_count < runes_needed :
			_get_active_character().is_active = false
			current_active_adventurer += 1
			
			if current_active_adventurer >= character_turn_order.size():
				current_active_adventurer = 0
			
			yield(get_tree().create_timer(1), "timeout")
			end_round.is_active = false		
			current_state = GameState.START_ROUND_ONE
		else:
			$win/active_bg.visible = true
			current_state = GameState.WIN
			pass	
		
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
		GameState.END_ROUND_TWO:
			_end_round_two(delta)
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
		SelectionWait.SWAP :
			field.shift_selection(selected_entities)
			pass
		SelectionWait.FIGHTER_ATTACK :
			# The field removes them anyway, so do nothing			
			pass
		SelectionWait.ROGUE_PLANT :
			# the field removes, filled with runes in pre-fill stage below
			pass
		SelectionWait.ROGUE_STEAL :
			for entity in selected_entities :
				_get_active_character().add(entity)
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
		SelectionWait.SWAP :
			current_state = GameState.END_ROUND
		SelectionWait.FIGHTER_ATTACK :
			current_state = GameState.END_ROUND
		SelectionWait.ROGUE_PLANT :
			current_state = GameState.END_ROUND
		SelectionWait.ROGUE_STEAL :
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
	current_selection_wait = SelectionWait.TAKE
	field.selection_length = result
	field.is_selection_allowed = true

# --------------------------
# ROUND TWO
# --------------------------

# SWAP THREE
func _on_abilities_action_box_swap_three_pressed():
	current_selection_wait = SelectionWait.SWAP
	field.selected_amount_to_reach = 3
	field.is_multi_select_allowed = true
	current_state = GameState.END_ROUND_TWO

# SWAP DICE
func _on_abilities_action_box_swap_dice_pressed(result : int):
	if result != 1 :
		current_selection_wait = SelectionWait.SWAP
		field.selected_amount_to_reach = result
		field.is_multi_select_allowed = true
		current_state = GameState.END_ROUND_TWO
		return
	current_state = GameState.END_ROUND
	return

func _on_field_post_swap_made():
	current_state = GameState.END_ROUND

# HEAL THREE
func _on_abilities_action_box_heal_three_pressed():
	_get_active_character().heal_highest(3)

# HEAL DICE
func _on_abilities_action_box_heal_dice_pressed(result : int):
	_get_active_character().heal_highest(result)

func _on_finished_healing_highest():
	current_state = GameState.END_ROUND
	pass # Replace with function body.

# --------------------------
# FIGHTER - ATTACK
# --------------------------

func _on_fighter_attack_action_cut_three_pressed():
	current_selection_wait = SelectionWait.FIGHTER_ATTACK
	field.selection_length = 3
	field.is_selection_allowed = true
	current_state = GameState.END_ROUND_TWO

func _on_fighter_attack_action_cut_dice_pressed(result : int):
	current_selection_wait = SelectionWait.FIGHTER_ATTACK
	field.selection_length = result
	field.is_selection_allowed = true
	current_state = GameState.END_ROUND_TWO

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
		if wound <= level :
			wounds_to_take.append(wound)
	
	for wound_to_take in wounds_to_take:
		character.heal(wound_to_take)
		var new_wound = FieldEntity.new()
		new_wound.type = "enemy"
		new_wound.level = wound_to_take - 1
		fighter.add(new_wound)


# --------------------------
# ROGUE - PLANT
# --------------------------
func _on_rogue_plant_action_plant_three_pressed():
	current_selection_wait = SelectionWait.ROGUE_PLANT
	field.is_selection_allowed = true
	field.selection_length = 3
	current_state = GameState.END_ROUND_TWO

func _on_rogue_plant_action_plant_dice_pressed(result : int):
	current_selection_wait = SelectionWait.ROGUE_PLANT
	field.is_selection_allowed = true
	field.selection_length = result
	current_state = GameState.END_ROUND_TWO


func _on_rogue_steal_action_steal_three_pressed():
	current_selection_wait = SelectionWait.ROGUE_STEAL
	field.is_multi_select_allowed = true
	field.selected_amount_to_reach = 3
	current_state = GameState.END_ROUND_TWO

func _on_rogue_steal_action_steal_dice_pressed(result : int):
	current_selection_wait = SelectionWait.ROGUE_STEAL
	field.is_multi_select_allowed = true
	field.selected_amount_to_reach = result
	current_state = GameState.END_ROUND_TWO

func _cleric_smite(damage : int):
	for x in field.WIDTH:
		for y in field.HEIGHT:
			var cell = field.field[x][y]
			if cell is FieldEntity:
				var fe : FieldEntity = cell
				if fe.type == "enemy" && fe.level < damage :
					field.field[x][y] = null				
	
	field.render()
	yield(get_tree().create_timer(1), "timeout")
	field.fill_gaps()
	field.render()
	current_state = GameState.END_ROUND
	pass

func _on_cleric_smite_action_smite_three_pressed():
	_cleric_smite(3)	

func _on_cleric_smite_action_smite_dice_pressed(result : int):
	_cleric_smite(result)

func _cleric_heal_wounds(character, level : int):
	var wounds = character.get_wounds()
	var wounds_to_heal = []
	for wound in wounds :
		if wound <= level :
			wounds_to_heal.append(wound)
	
	for wound_to_heal in wounds_to_heal:
		character.heal(wound_to_heal)

func _on_cleric_cure_action_cure_three_pressed():
	_cleric_heal_wounds(fighter, 3)
	_cleric_heal_wounds(rogue, 3)
	current_state = GameState.END_ROUND
	pass # Replace with function body.


func _on_cleric_cure_action_cure_dice_pressed(result : int):
	_cleric_heal_wounds(fighter, result)
	_cleric_heal_wounds(rogue, result)
	current_state = GameState.END_ROUND
	pass # Replace with function body.



