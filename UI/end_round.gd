tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$active_bg.visible = is_active
	pass
