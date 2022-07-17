extends Control

signal finished_healing
signal finished_healing_highest

const NUMERAL_SCENES = [
	preload("res://UI/numerals/one.tscn"),
	preload("res://UI/numerals/two.tscn"),
	preload("res://UI/numerals/three.tscn"),
	preload("res://UI/numerals/four.tscn"),
	preload("res://UI/numerals/five.tscn"),
	preload("res://UI/numerals/six.tscn"),
	preload("res://UI/numerals/seven.tscn"),
	preload("res://UI/numerals/eight.tscn"),
	preload("res://UI/numerals/nine.tscn"),
	preload("res://UI/numerals/ten.tscn")
]

export(String, "Fighter", "Rogue", "Cleric") var type = "Fighter"

export var is_active = false

onready var active_bg = $Panel/active_bg
onready var fighter_name = $Panel/name_labels/fighter_name
onready var rogue_name = $Panel/name_labels/rogue_name
onready var cleric_name = $Panel/name_labels/cleric_name

onready var wounds_container = $Panel/wounds_panel/HBoxContainer
onready var total_wounds_container = $Panel/total_wounds/Control

onready var injured_label = $Panel/state_labels/injured
onready var dead_label = $Panel/state_labels/dead

var is_dead = true
var is_injured = true

var red_rune_count = 0
var blue_rune_count = 0
var green_rune_count = 0

onready var red_rune_1 = $Panel/rune_inventory/r_1
onready var red_rune_2 = $Panel/rune_inventory/r_2
onready var red_rune_3 = $Panel/rune_inventory/r_3

onready var blue_rune_1 = $Panel/rune_inventory/b_1
onready var blue_rune_2 = $Panel/rune_inventory/b_2
onready var blue_rune_3 = $Panel/rune_inventory/b_3

onready var green_rune_1 = $Panel/rune_inventory/g_1
onready var green_rune_2 = $Panel/rune_inventory/g_2
onready var green_rune_3 = $Panel/rune_inventory/g_3

onready var can_use_ability = false
onready var ability_active_bg = $can_use_ability/Panel/active_bg
var rune_level_just_spent = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	match(type):
		"Fighter": fighter_name.visible = true
		"Rogue": rogue_name.visible = true
		"Cleric": cleric_name.visible = true
		
	update_inventory()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	active_bg.visible = is_active
	ability_active_bg.visible = is_active && can_use_ability && get_parent().current_state == get_parent().GameState.ROUND_TWO

	if red_rune_count == 3 || green_rune_count == 3 || blue_rune_count == 3 :
		enable_ability()
	else:
		disable_ability()

	var total_wounds = get_total_wounds()
	injured_label.visible = false
	is_injured = false
	is_dead = false
	if total_wounds >= 5 && total_wounds <= 10:
		injured_label.visible = true
		is_injured = true
		disable_ability()
	elif total_wounds >= 10:
		dead_label.visible = true		
		is_dead = true
		disable_ability()

func add(fieldEntity : FieldEntity):
	
	if fieldEntity:
		if fieldEntity.type == "enemy" :
			var numeral_scene = NUMERAL_SCENES[fieldEntity.level].instance()
			wounds_container.add_child(numeral_scene)
			update_total_wounds()
			pass
		
		elif fieldEntity.type == "rune" :
			match(fieldEntity.level):
				0: red_rune_count += 1
				1: green_rune_count += 1
				2: blue_rune_count += 1
			pass
			update_inventory()
		pass

func update_inventory():
	red_rune_count = clamp(red_rune_count, 0, 3)
	green_rune_count = clamp(green_rune_count, 0, 3)
	blue_rune_count = clamp(blue_rune_count, 0, 3)
	
	
	var red_runes = [red_rune_1, red_rune_2, red_rune_3]
	var blue_runes = [blue_rune_1, blue_rune_2, blue_rune_3]
	var green_runes = [green_rune_1, green_rune_2, green_rune_3]
	
	red_rune_1.modulate = "#50ffffff"
	red_rune_2.modulate = "#50ffffff"
	red_rune_3.modulate = "#50ffffff"
	blue_rune_1.modulate = "#50ffffff"
	blue_rune_2.modulate = "#50ffffff"
	blue_rune_3.modulate = "#50ffffff"
	green_rune_1.modulate = "#50ffffff"
	green_rune_2.modulate = "#50ffffff"
	green_rune_3.modulate = "#50ffffff"
		
	for i in red_rune_count:
		red_runes[i].modulate = Color.white

	for i in blue_rune_count:
		blue_runes[i].modulate = Color.white		
	
	for i in green_rune_count:
		green_runes[i].modulate = Color.white
	

	
	pass

func get_total_wounds():
	var total_wounds = 0
	for node in wounds_container.get_children():
		total_wounds += node.wound_value
		pass
	return total_wounds

func update_total_wounds():
	var total_wounds = get_total_wounds()
	
	total_wounds = clamp(total_wounds, 0, 10)
	var new_total_wounds = NUMERAL_SCENES[total_wounds -1].instance()
	
	var old = total_wounds_container.get_child(0)
	total_wounds_container.remove_child(old)
	if total_wounds != 0 :
		total_wounds_container.add_child(new_total_wounds)
	pass


func get_wounds():
	var wound_values = []
	for node in wounds_container.get_children():
		wound_values.append(node.wound_value)
	
	wound_values.sort()
	return wound_values
	pass

func get_total_rune_count():
	return red_rune_count + green_rune_count + blue_rune_count

func heal_highest(amount : int):
	var wound_values = []
	for node in wounds_container.get_children():
		wound_values.append(node.wound_value)
	
	wound_values.sort()
	var value_to_remove = null
	
	for index in range(wound_values.size() - 1, 0, -1):
		if wound_values[index] <= amount :
			value_to_remove = wound_values[index]
			break
	
	if value_to_remove:
		for node in wounds_container.get_children():
			if node.wound_value == value_to_remove :
				wounds_container.remove_child(node)
				break
	
	update_total_wounds()
	emit_signal("finished_healing_highest")
	pass

# heals one wound lower than the amount given
func heal(amount : int):
	var wound_values = []
	for node in wounds_container.get_children():
		wound_values.append(node.wound_value)
	
	wound_values.sort()
	var value_to_remove = null
	
	for value in wound_values:
		if value <= amount :
			value_to_remove = value
			break
	
	if value_to_remove:
		for node in wounds_container.get_children():
			if node.wound_value == value_to_remove :
				wounds_container.remove_child(node)
				break
	
	update_total_wounds()
	emit_signal("finished_healing")
	
	pass

func enable_ability():
	can_use_ability = true
	pass
	
func disable_ability():
	can_use_ability = false
	pass

func _spend_runes():
	if red_rune_count == 3 :
		red_rune_count = 0
		rune_level_just_spent = 0
	elif green_rune_count == 3 :
		green_rune_count = 0
		rune_level_just_spent = 1
	elif blue_rune_count == 3 :
		blue_rune_count = 0
		rune_level_just_spent = 2
		
	update_inventory()
	pass

func _on_fighter_attack_action_cut_three_pressed():
	_spend_runes()

func _on_fighter_attack_action_cut_dice_pressed():
	_spend_runes()

func _on_rogue_plant_action_ability_spend():
	_spend_runes()

func _on_rogue_steal_action_ability_spend():
	_spend_runes()

func _on_cleric_smite_action_ability_spend():
	_spend_runes()

func _on_cleric_cure_action2_ability_spend():
	_spend_runes()
