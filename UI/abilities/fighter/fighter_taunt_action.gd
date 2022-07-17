extends Control

signal taunt_three_pressed
signal taunt_dice_pressed

onready var three_button = $three_button2
onready var dice_button = $dice_button2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var is_fully_active = get_parent().can_use_ability && get_parent().is_active
		
	three_button.disabled = !is_fully_active
	dice_button.disabled = !is_fully_active
	
	pass


func _on_three_button2_pressed():
	emit_signal("taunt_three_pressed")
	pass # Replace with function body.


func _on_dice_button2_dice_rolled(result : int):
	emit_signal("taunt_dice_pressed", result)
	pass # Replace with function body.
