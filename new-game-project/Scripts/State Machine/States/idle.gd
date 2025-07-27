extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass #PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	var control = max(player.velocity.length(), player.ground_decel)
	var drop = control * player.ground_friction * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_speed /= player.velocity.length()
		
	player.velocity *= new_speed
	
	player.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(WALKING)
