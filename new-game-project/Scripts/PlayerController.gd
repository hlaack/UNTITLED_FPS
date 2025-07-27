class_name Player extends CharacterBody3D

#PLAYER SCENE REFERENCE VARIABLES
@onready var headcam : Camera3D = %Camera3D

#PLAYER CONTROLLER VARIABLES
@export var jump_velocity : float = 4.5

#AIR MOVEMENT SETTINGS
@export var air_cap : float = 0.5
@export var air_accel : float = 800.0
@export var air_move_speed : float = 800.0

#GROUND MOVEMENT SETTINGS
@export var walk_speed : float = 6.0
@export var sprint_speed : float = 8.5
@export var ground_accel : float = 14.0
@export var ground_decel : float = 10.0
@export var ground_friction : float = 2.0

var wish_dir : Vector3 = Vector3.ZERO

#HEAD BOB VARIABLES
const HEADBOB = 0.06
const HEADBOB_HZ = 2.4
var headbob_time : float = 0.0

#PLAYER MOUSE VARIABLES
@export var mouse_sens : float = 0.006

#func get_move_speed() -> float:
	#if Input.is_action_pressed("sprint") && not Input.is_action_pressed("backward"):
		#return sprint_speed
	#else:
		#return walk_speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sens)
			headcam.rotate_x(-event.relative.y * mouse_sens)
			headcam.rotation.x = clampf(headcam.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
		
#func headbob_fx(delta):
	#headbob_time += delta * self.velocity.length()
	#headcam.transform.origin = Vector3(
		#cos(headbob_time * HEADBOB_HZ * 0.5) * HEADBOB,
		#sin(headbob_time * HEADBOB_HZ) * HEADBOB,
		#0
	#)
		
func _process(delta):
	pass

#func air_move(delta) -> void:
	#self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	#
	##CLASSIC MOVEMENT RECIPE (QUAKE)
	#var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	#var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	#var add_speed_until_cap = capped_speed - cur_speed_in_wish_dir
	#
	#if add_speed_until_cap > 0:
		#var accel_speed = air_accel * air_move_speed * delta
		#accel_speed = min(accel_speed, add_speed_until_cap)
		#self.velocity += accel_speed * wish_dir

#func ground_move(delta) -> void:
	#var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	#var add_speed_until_cap = get_move_speed() - cur_speed_in_wish_dir
	#if add_speed_until_cap > 0:
		#var accel_speed = ground_accel * delta * get_move_speed()
		#accel_speed = min(accel_speed, add_speed_until_cap)
		#self.velocity += accel_speed * wish_dir
		#
	##APPLY FRICTION
	#var control = max(self.velocity.length(), ground_decel)
	#var drop = control * ground_friction * delta
	#var new_speed = max(self.velocity.length() - drop, 0.0)
	#if self.velocity.length() > 0:
		#new_speed /= self.velocity.length()
		#
	#self.velocity *= new_speed
	#
	#headbob_fx(delta)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward").normalized() #NORMALIZE VECTORS TO 1
	#wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) #STORE INPUT DIRECTIONS INTO VEC3

	#if is_on_floor():
		#if Input.is_action_just_pressed("jump"):
			#self.velocity.y = jump_velocity
		#ground_move(delta)
	#else:
		#air_move(delta)
		#
	#move_and_slide()
