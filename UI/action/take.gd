extends Control

signal regular_action_taken
signal dice_rolled

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var is_active : bool

onready var active_bg = $Panel/numeral_bg

onready var three_button = $Panel/three_button
onready var dice_button = $Panel/dice_button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	active_bg.visible = is_active
	three_button.disabled = !is_active
	dice_button.disabled = !is_active
	pass


func _on_three_button_pressed():
	self.is_active = false
	emit_signal("regular_action_taken")
	pass # Replace with function body.

func _on_dice_button_dice_rolled(result : int):
	self.is_active = false
	emit_signal("dice_rolled", result)
	pass # Replace with function body.
