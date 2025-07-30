extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	#PLAY ANIMS AND SOUNDS

func physics_update(delta: float) -> void:
	player.handle_crouch(delta)
	player.ground_move(delta)
	player.move_and_slide()
	
	if not player.is_on_floor():
			finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
			finished.emit(CROUCH_JUMPING)
	elif not player.is_crouched:
		if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			if Input.is_action_pressed("sprint"):
				finished.emit(SPRINTING)
			else:
				finished.emit(WALKING)
		else:
			finished.emit(IDLE)
