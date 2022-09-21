extends Area2D

onready var audio = $AudioStreamPlayer
onready var notifier = $VisibilityNotifier2D

func _ready():
	Global.init_coin()
	notifier.connect("screen_exited", self, "_on_screen_exited")

func collect():
	Global.collect_coin()
	audio.play(0)
	
func reposition_ahead():
	position.x += rand_range(1000, 2500)

func _on_Coin_body_entered(body):
	collect()
	reposition_ahead()

func _on_screen_exited():
	reposition_ahead()
