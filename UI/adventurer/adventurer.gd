extends Control

signal finished_healing

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
	pass

func add(fieldEntity : FieldEntity):
	
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

func update_total_wounds():
	var total_wounds = 0
	for node in wounds_container.get_children():
		total_wounds += node.wound_value
		pass
	
	total_wounds = clamp(total_wounds, 0, 10)
	var new_total_wounds = NUMERAL_SCENES[total_wounds -1].instance()
	
	var old = total_wounds_container.get_child(0)
	total_wounds_container.remove_child(old)
	total_wounds_container.add_child(new_total_wounds)
	pass

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
