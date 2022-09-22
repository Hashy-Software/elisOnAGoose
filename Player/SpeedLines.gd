extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rotated = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	"""
	var degrees = 2
	
	if rotated:
		rotate(degrees)
	else:
		rotate(-degrees)
	
	rotated = not rotated
	"""
	pass


func _on_Timer_timeout():
	rotation_degrees = (int(rotation_degrees) + 3) % 6
