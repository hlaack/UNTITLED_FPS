class_name PlayerState extends State

const IDLE = "Idle"
const WALKING = "Walking"
const SPRINTING = "Sprinting"
const JUMPING = "Jumping"
const FALLING = "Falling"
const CROUCHING = "Crouching"
const CROUCH_JUMPING = "Crouch_Jumping"
const SLIDING = "Sliding"
const DASHING = "Dashing"

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
