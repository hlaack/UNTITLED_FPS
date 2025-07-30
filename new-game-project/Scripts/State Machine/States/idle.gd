extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass #PLAY ANIMS AND SOUNDS
	
func physics_update(delta: float) -> void:
	player.ground_move(delta)
	player.handle_crouch(delta)
	player.velocity.y -= player.jump_gravity * delta
	player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(WALKING)
	elif Input.is_action_pressed("crouch"):
		finished.emit(CROUCHING)
	elif Input.is_action_just_pressed("dash") and player.dash_limit == 0:
		finished.emit(DASHING)
