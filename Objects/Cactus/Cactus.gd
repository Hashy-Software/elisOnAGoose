extends Area2D

onready var notifier = $VisibilityNotifier2D
onready var animation = $Animation

func _ready():
	notifier.connect("screen_exited", self, "_on_screen_exited")

func reposition_ahead():
	position.x += 2000
	animation.frame = (animation.frame + 1) % animation.frames.get_frame_count("default")

func _on_Cactus_body_entered(_body):
	# TODO: kill player
	pass

func _on_Cactus_screen_exited():
	reposition_ahead()
