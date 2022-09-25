extends Area2D

onready var notifier = $VisibilityNotifier2D
onready var animation = $Animation
onready var collision = $CollisionShape2D

func reposition_ahead():
	position.x += 2000
	animation.frame = randi() % animation.frames.get_frame_count("default")
	visible = bool(randi() % 2)
	collision.disabled = not visible

func _on_Cactus_screen_exited():
	reposition_ahead()
	
func _on_Cactus_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.has_method("death"):
		body.death("cactus")
