extends Control

signal cure_three_pressed
signal cure_dice_pressed

onready var three_button = $three_button
onready var dice_button = $dice_button

# this needs to be done before for rogue to track rune taken
signal ability_spend

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var is_fully_active = get_parent().can_use_ability && get_parent().is_active
		
	three_button.disabled = !is_fully_active
	dice_button.disabled = !is_fully_active
	
	
	pass


func _on_three_button_pressed():
	emit_signal("ability_spend")
	emit_signal("cure_three_pressed")
	pass # Replace with function body.


func _on_dice_button_dice_rolled(result : int):
	emit_signal("ability_spend")
	emit_signal("cure_dice_pressed", result)
	pass # Replace with function body.
