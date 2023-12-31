extends KinematicBody2D

onready var rot_tween = $RotTween
onready var stween = $STween
onready var sprite = $Sprite
onready var honk_audio = $HonkSoundStream

export var speed = 200

export var jump_height = 64.0
export var jump_time_to_peak = 0.3
export var jump_time_to_descent = 0.3

export var can_climb = true
export var climb_speed = 150
export var can_double_jump = true
export(int, 1, 100) var jump_count = 2
export var can_glide = true
export var can_gravity = true

export var is_death_enabled = true

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var DEFAULT_GRAVITY = Vector2(0,1).rotated(deg2rad(0)) #TODO Make Const
var gravity_influence = {}
var gravity_normal = DEFAULT_GRAVITY
var gravity_zchanged = false
var wind_influence = {}

var time_elapsed = 0
var drop_speed_multiplier = 1

var velocity = Vector2()

var jump = false
var jump_left = jump_count
var buffer_jump = false
var on_ground = false
var forced_jump = false

var is_dying = false
var death_by = ""
var initial_speed_backup = 0

var boost_normal = Vector2()
var boost_strength = speed*4
var boost_duration = 0

enum STATES {Walk, Jump, Fall}
var state = STATES.Walk
var burgers_hit = 0

enum STAGES {Normal, Stage1, Stage2}
var stage = STAGES.Normal

var last_state = state

func _ready():
	initial_speed_backup = speed
	speed = 0
#	check_abilities()

func _process(_delta):
	get_input()
	$Label.text = STATES.keys()[state]# + " -- " + str(rotation_degrees)
	
	if is_dying:
		$YouDiedCanvas.visible = true
		
		if death_by == "cactus":
			var player_shader = sprite.material
			var player_shader_progress = player_shader.get_shader_param("progress")
			speed = 0
			if player_shader_progress >= 1:
				Global.restart_game()
			else:
				player_shader.set_shader_param("progress", player_shader_progress + 0.008)
		
		elif death_by == "burger":
			if not $NukeSprites.visible:
				$NukeAudio.play(0.8)
				
			speed = 0
			sprite.visible = false
			$NukeSprites.visible = true
			$NukeSprites.playing = true
			
		else:
			Global.restart_game()

func _physics_process(delta):
	velocity.x = int(speed * delta * drop_speed_multiplier)
	last_state = state
	state = get_state()
	calculate_sprite()
	var snap = 8
	
	if is_on_floor():
		on_ground = true
		jump_left = jump_count
	else:
		#print("Player position = ", position)
		if $Coyote.is_stopped() && on_ground == true:
			$Coyote.start()
	
	if jump  || (buffer_jump && (on_ground || (jump_left > 0 && can_double_jump))):
		jump = false
		buffer_jump = false
		on_ground = false
		jump_left -= 1
		snap = 0
		last_state = state
		state = STATES.Jump
		
		velocity.y = jump_velocity
		if honk_audio.get_playback_position() == 0 || honk_audio.get_playback_position() >= 0.1 || !honk_audio.playing:
			honk_audio.play()
	else:
		velocity.y += get_gravity() * delta
	
	var ca = [abs(jump_gravity), abs(fall_gravity)].max()
	velocity.y = clamp(velocity.y,jump_velocity,ca/3)
	
	if boost_duration > 0:
		boost_duration -= delta
		velocity = boost_normal * boost_strength
	
	#Move and Slide
	calculate_gravity_normal()
	var grav_rot = gravity_normal.angle_to(Vector2(0,1))
	
	velocity = move_and_slide_with_snap(velocity.rotated(-grav_rot),gravity_normal*snap,-gravity_normal,true,4,deg2rad(80)).rotated(grav_rot)
	#velocity = move_and_slide_with_snap(velocity,Vector2(0,snap),Vector2.UP)

func get_input(): 
	
	var try_jump = false
		
	if Input.is_action_just_pressed("jump") || (Input.is_action_just_pressed("up") && on_ground && is_on_wall()):
		try_jump = true
	elif Input.is_action_just_pressed("down") && gravity_normal.y < 0:
		try_jump = true
	
	if forced_jump:
		try_jump = false
	
	if try_jump:
		if on_ground:
			jump = true
		else:
			buffer_jump = true
			$BufferJump.start()

func calculate_gravity_normal():
	var n_g = Vector2(0,0)
	
	if gravity_influence.empty() || !can_gravity:
		n_g = DEFAULT_GRAVITY
	else:
	#	var mk = ""
	#	for k in gravity_influence.keys():
	#		if mk == "":
	#			mk = k
	#			continue
	#
	#		if gravity_influence[k][0] > gravity_influence[mk][0]:
	#			mk = k
		
		var sum = Vector2()
		var d = 0
		
		for k in gravity_influence.keys():
			sum += gravity_influence[k][1]
			d += 1
		
		n_g = (sum/d).normalized()
	#	var n_g = gravity_influence[mk][1]
	if n_g != gravity_normal:
		gravity_normal = (7*gravity_normal + n_g)/8
		gravity_zchanged = true

func calculate_wind() -> Vector2:
	var wind_vec = Vector2(0,0)
	
	for v in wind_influence:
		wind_vec += wind_influence[v]
	
	return wind_vec

func calculate_sprite():
	sprite.playing = true
	
	var stage_suffix
	
	if stage == STAGES.Normal:
		stage_suffix = ""
	elif stage == STAGES.Stage1:
		stage_suffix = "_s1"
	elif stage == STAGES.Stage2:
		stage_suffix = "_s2"
	
	if state == STATES.Walk:
		sprite.animation = "walk" + stage_suffix
	elif state == STATES.Jump:
		sprite.scale = (sprite.scale + Vector2(1.18,0.85))/2
		
#		if last_state != STATES.Jump:
#			print("Jump")
#			stween.remove_all()
#			stween.interpolate_property(sprite,"scale",null,Vector2(1.25,0.8),0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
#			stween.start()
		sprite.animation = "jump" + stage_suffix
	elif state == STATES.Fall:
		if !is_on_ceiling():
			if last_state != STATES.Fall:
				stween.remove_all()
				stween.interpolate_property(sprite,"scale",null,Vector2(0.85,1.18),0.35,Tween.TRANS_SINE,Tween.EASE_OUT)
				stween.start()
			sprite.animation = "fall" + stage_suffix
	
	if state != STATES.Jump && state != STATES.Fall && sprite.scale != Vector2(1,1):
		if last_state == STATES.Jump || last_state == STATES.Fall:
			stween.remove_all()
		
		if !stween.is_active():
			stween.remove_all()
			stween.interpolate_property(sprite,"scale",null,Vector2(1,1),0.2,Tween.TRANS_BACK,Tween.EASE_OUT)
			stween.start()


func get_state():
	var n_state = STATES.Walk
	
	if is_on_floor():
		n_state = STATES.Walk
	elif !is_on_floor() && velocity.y < 0:
		n_state = STATES.Jump
	elif !is_on_floor() && velocity.y > 0:
		n_state = STATES.Fall

	return n_state

func get_gravity():
	if state == STATES.Jump:
		if !Input.is_action_pressed("jump"):
			return jump_gravity*1.5
		return jump_gravity
	
	return fall_gravity

func force_jump():
	jump_left = jump_count
	jump = true
	
	if !forced_jump:
		forced_jump = true
		$ForceJump.start()
		return true
	return false

func boost():
	boost_normal.x = sign(round(velocity.x))
	boost_normal.y = sign(round(velocity.y))
	boost_normal = boost_normal.normalized()
	
	if round(boost_normal.x) == 0 && round(boost_normal.y) == 0:
		return false
	
	if boost_normal.y > 0:
		boost_normal.y /= -4
	else:
		boost_normal.y /=2
	
	boost_duration = 0.1
	return true

func check_abilities():
	can_climb = Global.has_ability("climb")
	can_double_jump = Global.has_ability("double_jump")
	can_glide = Global.has_ability("glide")
	can_gravity = Global.has_ability("gravity")

func death(reason):
	if is_death_enabled:
		death_by = reason
		is_dying = true

func teleport(to: Vector2):
	set_position(to)

func is_player():
	return true

func _on_SpeedLinesRotation_timeout():
	if $SpeedLinesCanvas/SpeedLines.visible:
		$SpeedLinesCanvas/SpeedLines.rotation_degrees = rand_range(-8, 8)

func _on_Timer_timeout():
	time_elapsed += 1

	var drop_start_times = [40, 103, 178, 229, 242]
	var drop_duration = 12
	var drop_stop_times = []
	
	for time in drop_start_times:
		drop_stop_times.append(time + drop_duration)
		
	if time_elapsed in drop_stop_times:
		$SpeedLinesCanvas.visible = false
		drop_speed_multiplier = 1
	elif time_elapsed in drop_start_times:
		$SpeedLinesCanvas.visible = true
		drop_speed_multiplier = 1.3

func _on_SpeedIncreaseTimer_timeout():
	if speed < 2 * initial_speed_backup:
		speed += int(initial_speed_backup / 100)
		sprite.speed_scale += 0.03
		#print("Player speed=", speed, " animation speed scale=", sprite.speed_scale)

func _on_NukeSprites_animation_finished():
	Global.restart_game()
