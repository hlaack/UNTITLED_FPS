extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass #PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	player.handle_crouch(delta)
	player.ground_move(delta)
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif not Input.is_action_pressed("sprint") and not player.input_dir.is_zero_approx():
		finished.emit(WALKING)
	elif player.input_dir.is_zero_approx():
		finished.emit(IDLE)
	elif Input.is_action_just_pressed("crouch"):
		finished.emit(SLIDING)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
