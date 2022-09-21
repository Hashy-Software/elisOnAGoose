extends Label

var completed = false

func _ready():
	update_text()

func _process(_delta):
	update_text()

func update_text():
	text = str(Global.current_coins)
