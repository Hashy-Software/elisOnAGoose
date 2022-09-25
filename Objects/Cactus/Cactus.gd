extends Area2D

onready var notifier = $VisibilityNotifier2D
onready var animation = $Animation
onready var collision = $CollisionShape2D

func _ready():
	notifier.connect("screen_exited", self, "_on_screen_exited")

func reposition_ahead():
	position.x += 2000
	animation.frame = randi() % animation.frames.get_frame_count("default")
	visible = bool(randi() % 2)
	collision.disabled = not visible

func _on_Cactus_screen_exited():
	reposition_ahead()
	
func _on_Cactus_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.has_method("death"):
		body.death()
