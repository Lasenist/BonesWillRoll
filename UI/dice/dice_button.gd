extends Button

const ENABLED_COLOUR = "#FFFFFF"
const DISABLED_COLOUR = "#919191"

signal dice_rolled

signal show_dice_roll_result

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var dice = $dice
onready var animated_sprite : AnimatedSprite = $dice/AnimatedSprite

var is_waiting_to_show_result = false
var result

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dice.visible = !self.disabled 
	
#	if is_waiting_to_show_result && animated_sprite.frame == result - 1:
#		animated_sprite.stop()
#		is_waiting_to_show_result = false
#		yield(get_tree().create_timer(1),"timeout")
#		emit_signal("dice_rolled", result)
#		animated_sprite.play()
#		disabled = true
#		result = null
#		pass


func _on_dice_button_pressed():
	if !is_waiting_to_show_result :
		
		result = RNGTools.randi_range(1, 6)
		emit_signal("dice_rolled", result)
		emit_signal("show_dice_roll_result", result)
		disabled = true
		result = null
	pass # Replace with function body.
