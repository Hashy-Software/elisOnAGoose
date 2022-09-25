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

func _on_BurgerArea_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	reposition_ahead()
	munch_player.play(1.2)

func _on_screen_exited():
	reposition_ahead()
