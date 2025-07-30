extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = player.jump_velocity
	#PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	player.air_move(delta)
	player.move_and_slide()
	
	if player.velocity.y < 0.0:
		finished.emit(FALLING)
	elif player.velocity.y > 0.0 and Input.is_action_pressed("crouch"):
		finished.emit(CROUCH_JUMPING)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
	elif player.slope_detect.is_colliding() and player.velocity.y <= 0.0:
		if not player.input_dir.is_zero_approx():
			if Input.is_action_pressed("sprint"):
				finished.emit(SPRINTING)
			else:
				finished.emit(WALKING)
		elif player.input_dir.is_zero_approx():
			finished.emit(IDLE)
