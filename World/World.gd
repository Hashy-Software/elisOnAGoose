extends Node2D

onready var transition = $UI/Transition
onready var player = $Player
onready var player_sprite = $Player/Sprite
onready var dino = $Dino
onready var dino_sprite = $Dino/Sprite
onready var dino_animated_sprite = $Dino/AnimatedSprite

var _start_pixel_explosion = false

func _process(_delta):
	if _start_pixel_explosion:
		var dino_shader = dino_sprite.material
		var dino_shader_progress = dino_shader.get_shader_param("progress")
		
		if dino_shader_progress > 1:
			player.speed = player.initial_speed_backup
			dino_animated_sprite.visible = false
			dino_sprite.visible = false
			_start_pixel_explosion = false
		elif dino_shader_progress > 0.5:
			player.visible = true
		
		dino_shader.set_shader_param("progress", dino_shader_progress + 0.01)

func _ready():
	Global.text_box = ""
	transition.open()
	$Dino/StartPixelExplosion.start()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		var _error = get_tree().change_scene("res://UI/Menu.tscn")
		
func _on_GasGasGas_finished():
	player.time_elapsed = 0
	$GasGasGas.play(0)

func _on_StartPixelExplosion_timeout():
	_start_pixel_explosion = true
	dino_sprite.visible = true
	dino_animated_sprite.visible = false

func _on_HideDoubleJumpLabel_timeout():
	$DoubleJumpLabel.visible = false
