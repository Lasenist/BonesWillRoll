extends Node2D

signal selection_made
signal post_selection_made
signal pre_fill_field
signal post_swap_made

const WIDTH = 6
const HEIGHT = 6
const RUNE_SCENE = preload("res://rune/rune.tscn")
const ENEMY_SCENE = preload("res://enemy/enemy.tscn")

# Map for tilemap tiles to use in code
const CELL_DEFAULT = 0
const CELL_HOVER = 1
const CELL_ERR = 2
const CELL_SELECTION = 3

enum FieldState {
	NONE,
	LINE_SELECT,
	LINE_SELECT_COMPLETION
	MULTI_SELECT,
	MULTI_SELECTION_COMPLETION
}
var current_state = FieldState.NONE

# Queue of incoming entities
var incoming_entities = []
# The current playing field, a 2d array
var field = null

# Tilemap used to render empty squares, and get co-ord space
onready var tilemap = $TileMap
# Scenes of enemies and runes on the field
onready var entities = $TileMap/entities

onready var select_targets_message = $select_targets

# for hovering when taking
var is_mouse_over_field = false
var is_selection_allowed = false

# for multi selection
var is_multi_select_allowed = false
var selected_amount_to_reach = 3
var selected_cells = []

var direction_order = [
	Vector2.UP, 
	Vector2.UP + Vector2.RIGHT, 
	Vector2.RIGHT, 
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.LEFT,
	Vector2.LEFT + Vector2.UP
	]
var selection_direction = 0
var selection_length = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var entity_type_weighted_bag := RNGTools.WeightedBag.new()
	entity_type_weighted_bag.weights = {
		Enemy = 7,
		Rune = 3
	}	
	
	var enemy_level_weighted_bag := RNGTools.WeightedBag.new()
	enemy_level_weighted_bag.weights = {
		One = 50,
		Two = 25,
		Three = 12,
		Four = 6,
		Five = 3
	}
	
	build_incoming_entities(1000, entity_type_weighted_bag, enemy_level_weighted_bag)
	
	field = create_2d_array(WIDTH, HEIGHT, null)
	
	fill_gaps()
	render()
	
	pass # Replace with function body.

func create_2d_array(width, height, value):
	var a = []

	for x in range(width):
		a.append([])
		a[x].resize(height)
		for y in range(height):
			a[x][y] = value

	return a

func _build_new_enemy(p_level : int):
	var result = FieldEntity.new()
	result.type = "enemy"
	result.level = p_level
	return result

func _build_new_rune(p_type : int):
	var result = FieldEntity.new()
	result.type = "rune"
	result.level = p_type
	return result

func build_incoming_entities(p_count : int, p_type_weighted_bag : RNGTools.WeightedBag, p_enemy_type_weighted_bag : RNGTools.WeightedBag):
	
	for i in p_count:
		var type = RNGTools.pick_weighted(p_type_weighted_bag)
		var new_entity = null
		match(type):
			"Enemy":
				var enemy_level = RNGTools.pick_weighted(p_enemy_type_weighted_bag)
				match(enemy_level):
					"One":
						new_entity = _build_new_enemy(0)
					"Two":
						new_entity = _build_new_enemy(1)
					"Three":
						new_entity = _build_new_enemy(2)
					"Four":
						new_entity = _build_new_enemy(3)
					"Five":
						new_entity = _build_new_enemy(4)
				pass
			"Rune":                          # R, G, B
				var rune_type = RNGTools.pick([0, 1, 2]) 
				new_entity = _build_new_rune(rune_type)
				pass
			_:
				assert(false)
		
		incoming_entities.append(new_entity)
	pass

func fill_gaps():
	
	for x in WIDTH:
		for y in HEIGHT:
			var cell = field[x][y]
			if cell == null:
				field[x][y] = incoming_entities.pop_front()
				pass
			pass
	pass

func fill_gaps_with_rune(entity : FieldEntity):
	for x in WIDTH:
		for y in HEIGHT:
			var cell = field[x][y]
			if cell == null:
				field[x][y] = entity
				pass
			pass
	pass



func render():
	
	for i in entities.get_children():
		entities.remove_child(i)
	
	for x in WIDTH:
		for y in HEIGHT:
			var entity : FieldEntity = field[x][y]
			if entity :
				match(entity.type):
					"enemy":
						var enemy = ENEMY_SCENE.instance()
						enemy.level = entity.level
						enemy.position = tilemap.map_to_world(Vector2(x,y))
						entities.add_child(enemy)
						pass
					"rune":
						var rune = RUNE_SCENE.instance()
						rune.type = entity.level
						rune.position = tilemap.map_to_world(Vector2(x,y))
						entities.add_child(rune)
						pass
				pass
		pass
	pass

func _line_select(delta):
	select_targets_message.visible = true
	
	if Input.is_action_just_pressed("rotate_selection_left") :
		selection_direction -= 1
	
	if Input.is_action_just_pressed("rotate_selection_right") :
		selection_direction += 1
	
	if selection_direction >= direction_order.size():
		selection_direction = 0
	elif selection_direction < 0 :
		selection_direction = direction_order.size() -1		 
	
	selection_direction = clamp(selection_direction, 0, direction_order.size() - 1)
	
	if is_mouse_over_field :
		render_mouse_hover(direction_order[selection_direction], selection_length)
		if Input.is_mouse_button_pressed(1) :
			var hovered_cells = take_hover()
			
			if hovered_cells.size() == selection_length:	
				is_selection_allowed = false
				var selected_entities = []
				
				for vector in hovered_cells:
					selected_entities.append(field[vector.x][vector.y])
					field[vector.x][vector.y] = null
				
				emit_signal("selection_made", selected_entities)
				clear_hover()
				emit_signal("pre_fill_field")
				fill_gaps()
				render()
				emit_signal("post_selection_made")

			current_state = FieldState.NONE
			return
	pass

func _multi_select(delta):
	select_targets_message.visible = true
	
	if is_mouse_over_field :
		render_mouse_hover(direction_order[selection_direction], 1)
	
		if Input.is_mouse_button_pressed(1) :
			var selected_cells = select_hover()
			
			if selected_cells.size() == selected_amount_to_reach :
				is_multi_select_allowed = false
		
				var selected_entities = []
				for cell in selected_cells:
					selected_entities.append(field[cell.x][cell.y])
					field[cell.x][cell.y] = null

				last_selected_cells = selected_cells
				emit_signal("selection_made", selected_entities)
				clear_selection()
				emit_signal("pre_fill_field")
				fill_gaps()
				render()
				emit_signal("post_selection_made")
				last_selected_cells = null
				selected_cells = []
	pass

func _process(delta):
	select_targets_message.visible = false
	clear_hover()
	
	if is_selection_allowed :
		current_state = FieldState.LINE_SELECT
	
	elif is_multi_select_allowed :
		current_state = FieldState.MULTI_SELECT
	
	match current_state:
		FieldState.LINE_SELECT:
			_line_select(delta);
		FieldState.MULTI_SELECT:
			_multi_select(delta);
			
	pass

# ------------------
# SELECTION
# ------------------
func clear_hover():
	var hovered_cells : Array = tilemap.get_used_cells_by_id(CELL_HOVER)
	for cell in hovered_cells:
		tilemap.set_cellv(cell, CELL_DEFAULT)
		pass
		
	var err_cells : Array = tilemap.get_used_cells_by_id(CELL_ERR)
	for cell in err_cells:
		tilemap.set_cellv(cell, CELL_DEFAULT)
		pass

func clear_selection():
	var hovered_cells : Array = tilemap.get_used_cells_by_id(CELL_HOVER)
	for cell in hovered_cells:
		tilemap.set_cellv(cell, CELL_DEFAULT)
		pass
	
	var selected_cells : Array = tilemap.get_used_cells_by_id(CELL_SELECTION)
	for cell in selected_cells:
		tilemap.set_cellv(cell, CELL_DEFAULT)
	pass

func render_mouse_hover(p_dir : Vector2, p_length : int) -> void:
	var cell_mouse_is_over : Vector2 = tilemap.world_to_map(tilemap.get_local_mouse_position())
	var cells_to_select = []
	for i in p_length:
		var cell_position = cell_mouse_is_over + p_dir * i
		if !(cell_position.x < 0 || cell_position.x >= WIDTH || 
			cell_position.y < 0 || cell_position.y >= HEIGHT) :
			cells_to_select.append(cell_position)
		
	var selection_type = CELL_ERR if cells_to_select.size() != p_length else CELL_HOVER
		
	for vector in cells_to_select:
		# don't mark tiles that are selected for hover
		if tilemap.get_cellv(vector) != CELL_SELECTION :
			tilemap.set_cellv(vector, selection_type )
	pass

func take_hover() -> Array:
	var hovered_cells = tilemap.get_used_cells_by_id(CELL_HOVER)
	return hovered_cells

var last_selected_cells = []
func shift_selection(selected_entities):
	var shifted_array = _shiftRight(selected_entities)

	var count = 0
	for cell in selected_cells:
		field[cell.x][cell.y] = shifted_array[count]
		count += 1
	pass

func select_hover() -> Array :
	var hovered_cells = tilemap.get_used_cells_by_id(CELL_HOVER)
	
	for cell in hovered_cells:
		tilemap.set_cellv(cell, CELL_SELECTION)
		selected_cells.append(cell)
	
	return selected_cells
	
		
func _shiftRight( array : Array ):
	var last = array[array.size() - 1]

	# shift right
	for i in range(array.size() - 2, -1, -1):
		array[i + 1] = array[i];

	# wrap last element into first slot
	array[0] = last;
	return array

func _on_mouse_area_mouse_entered():
	is_mouse_over_field = true
	pass # Replace with function body.


func _on_mouse_area_mouse_exited():
	is_mouse_over_field = false
	pass # Replace with function body.
