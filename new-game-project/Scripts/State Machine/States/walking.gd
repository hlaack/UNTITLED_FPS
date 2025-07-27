extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass #PLAY ANIMS AND SOUNDS

func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward").normalized() #NORMALIZE VECTORS TO 1
	player.wish_dir = player.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) #STORE INPUT DIRECTIONS INTO VEC3
	
	ground_move_walking(delta)
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("sprint") and not input_dir.is_zero_approx():
		finished.emit(SPRINTING)
	elif input_dir.is_zero_approx():
		finished.emit(IDLE)

func headbob_fx(delta):
	player.headbob_time += delta * player.velocity.length()
	player.headcam.transform.origin = Vector3(
		cos(player.headbob_time * player.HEADBOB_HZ * 0.5) * player.HEADBOB,
		sin(player.headbob_time * player.HEADBOB_HZ) * player.HEADBOB,
		0
	)

func ground_move_walking(delta) -> void:
	var cur_speed_in_wish_dir = player.velocity.dot(player.wish_dir)
	var add_speed_until_cap = player.walk_speed - cur_speed_in_wish_dir
	if add_speed_until_cap > 0:
		var accel_speed = player.ground_accel * delta * player.walk_speed
		accel_speed = min(accel_speed, add_speed_until_cap)
		player.velocity += accel_speed * player.wish_dir
		
	#APPLY FRICTION
	var control = max(player.velocity.length(), player.ground_decel)
	var drop = control * player.ground_friction * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_speed /= player.velocity.length()
		
	player.velocity *= new_speed
	
	headbob_fx(delta)
