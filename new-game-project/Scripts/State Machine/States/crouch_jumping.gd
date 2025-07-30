extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	if player.velocity.y == 0.0:
		player.velocity.y = player.jump_velocity
	
func physics_update(delta: float) -> void:
	player.handle_crouch(delta)
	
	player.air_move(delta)
	player.move_and_slide()
	
	if player.velocity.y <= 0.0:
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
