tool
extends Node2D

const sprites = {
	0 : "res://rune/red.png",
	1 : "res://rune/green.png",
	2 : "res://rune/blue.png"
	};

export(int, 0, 1, 2) var type : int

onready var sprite : Sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = load(sprites.get(self.type));
	pass # Replace with function body.
