tool
extends Node2D

const sprites = [
	"res://enemy/one.png",
	"res://enemy/two.png",
	"res://enemy/three.png",
	"res://enemy/four.png",
	"res://enemy/five.png"
	];

export(int, 0, 4) var level : int

onready var sprite : Sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = load(sprites[level]);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
