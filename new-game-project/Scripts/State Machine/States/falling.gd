extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass #PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	player.handle_crouch(delta)
	player.air_move(delta)
	player.move_and_slide()
	
	if player.is_on_floor():
		if not player.input_dir.is_zero_approx():
			if Input.is_action_pressed("sprint"):
				finished.emit(SPRINTING)
			elif Input.is_action_pressed("crouch"):
				finished.emit(SLIDING)
			else:
				finished.emit(WALKING)
		elif player.input_dir.is_zero_approx():
			if player.velocity.length() != 0.0 and Input.is_action_pressed("crouch"):
				finished.emit(SLIDING)
			else:
				finished.emit(IDLE)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
