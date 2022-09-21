extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var notifier = $VisibilityNotifier2D
onready var munch_player = $MunchPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	notifier.connect("screen_exited", self, "_on_screen_exited")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reposition_ahead():
	position.x += rand_range(1000, 2500)

func _on_BurgerArea_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	reposition_ahead()
	munch_player.play(1.2)

func _on_screen_exited():
	reposition_ahead()
