extends Control

signal swap_three_pressed
signal swap_dice_pressed

signal heal_three_pressed
signal heal_dice_pressed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var is_active : bool

onready var active_bg = $Panel/numeral/numeral_bg

onready var three_button = $Panel/swap_action/three_button
onready var dice_button = $Panel/swap_action/dice_button

onready var heal_button = $Panel/heal_action/three_button
onready var dice_heal_button = $Panel/heal_action/three_button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	active_bg.visible = is_active
	three_button.disabled = !is_active
	dice_button.disabled = !is_active
	
	heal_button.disabled = !is_active
	dice_heal_button.disabled = !is_active
	pass


func _on_swap_three_button_pressed():
	emit_signal("swap_three_pressed")
	pass # Replace with function body.

func _on_dice_button_dice_rolled(result : int):
	emit_signal("swap_dice_pressed", result)
	pass # Replace with function body.

func _on_heal_three_button_pressed():
	emit_signal("heal_three_pressed")
	pass # Replace with function body.

func _on_heal_dice_button_dice_rolled(result : int):
	emit_signal("heal_dice_pressed")
	pass # Replace with function body.
