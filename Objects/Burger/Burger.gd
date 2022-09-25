extends Node2D

export var is_visible = true
export var has_collision = true

onready var notifier = $BurgerArea/VisibilityNotifier2D
onready var munch_player = $BurgerArea/MunchPlayer
onready var collision = $BurgerArea/BurgerCollisionShape
onready var animation = $BurgerArea/BurgerAnimation

func _ready():
	visible = is_visible
	collision.disabled = not has_collision
	notifier.connect("screen_exited", self, "_on_screen_exited")

func reposition_ahead():
	visible = bool(randi() % 2)
	collision.disabled = not visible
	position.x += 2000

func _on_BurgerArea_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	reposition_ahead()
	
	if body.has_method("is_player"):
		body.burgers_hit += 1
		
		if body.burgers_hit <= 2:
			body.stage = body.STAGES.Stage1
		elif body.burgers_hit <= 4:
			body.stage = body.STAGES.Stage2
		elif body.burgers_hit >= 6:
			body.death("burger")
	
	munch_player.play(1.2)

func _on_screen_exited():
	reposition_ahead()
