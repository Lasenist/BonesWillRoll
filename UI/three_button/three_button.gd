tool
extends Button

const ENABLED_COLOUR = "#FFFFFF"
const DISABLED_COLOUR = "#919191"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var three = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.disabled :
		three.self_modulate = DISABLED_COLOUR
	else:
		three.self_modulate = ENABLED_COLOUR
