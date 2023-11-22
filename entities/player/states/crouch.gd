extends PlayerState


@export var crouch_speed := 6


func enter() -> void:
	player.anim_player.play("player/crouch")
	player.speed = crouch_speed
	player.weapon.recoil_randomness /= 2.0


func exit() -> void:
	player.anim_player.play_backwards("player/crouch")


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("idle" if not _get_normalized_direction() else "walk")
	elif event.is_action_pressed("sprint") and player.weapon.can_sprint:
		finished.emit("sprint")
	
	return super(event)


func update(delta: float) -> void:
	_move(delta)
