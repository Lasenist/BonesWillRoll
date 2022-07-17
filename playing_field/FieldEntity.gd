extends Resource
class_name FieldEntity

export(String, "rune", "enemy") var type : String
export(int) var level : int

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_type = "rune", p_level = 0):
	type = p_type
	level = p_level

