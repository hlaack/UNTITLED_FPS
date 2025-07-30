#TODO: Implement Dash state
#https://forum.godotengine.org/t/how-would-i-go-about-making-a-character-dash-to-where-he-is-looking-at-in-an-fps/21809/2

extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	
func physics_update(delta: float) -> void:
	player.dash(delta)
	player.handle_crouch(delta)
	player.move_and_slide()
	
	if player.dash_finished == true:
		if not player.is_on_floor() and player.velocity.y > 0.0:
			finished.emit(FALLING)
		elif not player.input_dir.is_zero_approx():
			if Input.is_action_pressed("sprint"):
				finished.emit(SPRINTING)
			else:
				finished.emit(WALKING)
		elif player.input_dir.is_zero_approx():
			if Input.is_action_pressed("crouch"):
				finished.emit(CROUCHING)
			else:
				finished.emit(IDLE)
	
