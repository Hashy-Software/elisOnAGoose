extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var notifier = $VisibilityNotifier2D


# Called when the node enters the scene tree for the first time.
func _ready():
	notifier.connect("screen_exited", self, "_on_screen_exited")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reposition_ahead():
	position.x += rand_range(1000, 2500)

func _on_BurgerArea_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	reposition_ahead()

func _on_screen_exited():
	reposition_ahead()
