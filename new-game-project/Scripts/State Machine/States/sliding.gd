extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	
func physics_update(delta: float) -> void:	
	player.handle_crouch(delta)
	player.velocity.x = move_toward(player.velocity.x, 0.0, 1.5 * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, 1.5 * delta)
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("crouch"):
			finished.emit(CROUCH_JUMPING)
		else:
			finished.emit(JUMPING)
	elif not player.input_dir.is_zero_approx() and not player.is_crouched:
		if Input.is_action_pressed("sprint"):
			finished.emit(SPRINTING)
		else:
			finished.emit(WALKING)
	elif player.velocity.length() <= 6.0:
		finished.emit(CROUCHING)
	elif player.input_dir.is_zero_approx():
		finished.emit(IDLE)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
	
