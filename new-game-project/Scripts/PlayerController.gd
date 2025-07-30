class_name Player extends CharacterBody3D

#PLAYER SCENE REFERENCE VARIABLES
@onready var headcam : Camera3D = %Camera3D
@onready var mesh : CSGMesh3D = %CSGMesh3D
@onready var collider : CollisionShape3D = %CollisionShape3D
@onready var head_node : Node3D = %Head
@onready var slope_detect : RayCast3D = %slope_detection

#PLAYER CONTROLLER VARIABLES
@export var jump_peak_time : float = 0.40
@export var jump_fall_time : float = 0.40
@export var jump_height : float = 1.0
@export var jump_distance : float = 3.0
var jump_velocity : float = 5.0
var jump_gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

#CROUCH SETTINGS
var is_crouched : bool = false
const CROUCH_TRANSLATE : float = 0.7
const CROUCH_JUMP_ADD : float = CROUCH_TRANSLATE * 0.9
var crouch_speed : float = 4.0
@onready var og_capsule_height = collider.shape.height
var was_crouched_last_frame : bool = false

#DASH SETTINGS
@export var dash_distance : float = 15.0
var dash_finished : bool = false
var dash_limit : int = 0

#AIR MOVEMENT SETTINGS
@export var air_cap : float = 0.75
@export var air_accel : float = 800.0
@export var air_move_speed : float = 1200.0

#GROUND MOVEMENT SETTINGS
@export var walk_speed : float = 6.0
@export var sprint_speed : float = 8.5
@export var ground_accel : float = 14.0
@export var ground_decel : float = 10.0
@export var ground_friction : float = 4.0
@export var slide_boost : float = 3.0

var wish_dir : Vector3 = Vector3.ZERO
var input_dir : Vector2 = Vector2.ZERO

#HEAD BOB VARIABLES
const HEADBOB = 0.06
const HEADBOB_HZ = 2.4
var headbob_time : float = 0.0

#PLAYER MOUSE VARIABLES
@export var mouse_sens : float = 0.006

func _ready() -> void:
	calc_move_params()

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
		
func _process(delta):
	pass

func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "forward", "backward").normalized() #NORMALIZE VECTORS TO 1
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) #STORE INPUT DIRECTIONS INTO VEC3

#STATE FUNCTIONS

func calc_move_params() -> void:
	jump_gravity = (2.0 * jump_height) / pow(jump_peak_time, 2.0)
	jump_velocity = jump_gravity * jump_peak_time
	
func get_move_speed() -> float:
	if is_crouched:
		return crouch_speed
	elif Input.is_action_pressed("sprint"):
		return sprint_speed
	else:
		return walk_speed
	
func handle_crouch(delta) -> void:
	was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("crouch"):
		is_crouched = true
	elif is_crouched and not test_move(global_transform, Vector3(0.0, CROUCH_TRANSLATE, 0.0)):
		is_crouched = false
		
	var translate_y_if_possible : float = 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor():
		translate_y_if_possible = CROUCH_JUMP_ADD if is_crouched else -CROUCH_JUMP_ADD
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(global_transform, Vector3(0.0, translate_y_if_possible, 0.0), result)
		self.position.y += result.get_travel().y
		head_node.position.y -= result.get_travel().y
		head_node.position.y = clampf(head_node.position.y, -CROUCH_TRANSLATE, 0)
		
	head_node.position.y = move_toward(head_node.position.y, -CROUCH_TRANSLATE if is_crouched else 0.0, 10.0 * delta)
	collider.shape.height = og_capsule_height - CROUCH_TRANSLATE if is_crouched else og_capsule_height
	collider.position.y = collider.shape.height / 2.0
	
func headbob_fx(delta):
	headbob_time += delta * velocity.length()
	headcam.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_HZ * 0.5) * HEADBOB,
		sin(headbob_time * HEADBOB_HZ) * HEADBOB,
		0
	)

func ground_move(delta) -> void:
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var add_speed_until_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_until_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_until_cap)
		velocity += accel_speed * wish_dir
		
	#APPLY FRICTION
	var control = max(velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
		
	velocity *= new_speed
	
	headbob_fx(delta)
	
func air_move(delta) -> void:
	velocity.y -= jump_gravity * delta
	
	#CLASSIC MOVEMENT RECIPE (QUAKE)
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_until_cap = capped_speed - cur_speed_in_wish_dir
	
	if add_speed_until_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_until_cap)
		velocity += accel_speed * wish_dir
		
func dash(delta) -> void:
	#NOTE: DASH HEIGHT APPROX 8 METERS
	if dash_limit == 0:
		dash_finished = false
		var dash_direction : Vector3 = -headcam.global_transform.basis.z
		print(dash_direction)
		var end_dash := self.global_position + dash_direction * dash_distance
		
		self.velocity = (end_dash - self.global_position).normalized() * dash_distance
		dash_finished = true
	
	dash_limit = 1
	await get_tree().create_timer(4.0).timeout
	dash_limit = 0
	print("Dash limit reset.")
