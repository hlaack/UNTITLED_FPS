extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = player.jump_velocity
	#PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward").normalized() #NORMALIZE VECTORS TO 1
	player.wish_dir = player.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) #STORE INPUT DIRECTIONS INTO VEC3
	
	air_move(delta)
	player.move_and_slide()
	
	if player.velocity.y <= 0.0:
		finished.emit(FALLING)
	
func air_move(delta) -> void:
	player.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	#CLASSIC MOVEMENT RECIPE (QUAKE)
	var cur_speed_in_wish_dir = player.velocity.dot(player.wish_dir)
	var capped_speed = min((player.air_move_speed * player.wish_dir).length(), player.air_cap)
	var add_speed_until_cap = capped_speed - cur_speed_in_wish_dir
	
	if add_speed_until_cap > 0:
		var accel_speed = player.air_accel * player.air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_until_cap)
		player.velocity += accel_speed * player.wish_dir
