extends PlayerState


func enter() -> void:
	player.speed = 0
	if player.weapon:
		player.weapon.recoil_randomness = player.weapon.DEFAULT_RECOIL_RANDOMNESS


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed(&"crouch"):
		finished.emit("crouch")
	return super(event)


func update(delta: float) -> void:
	if _get_normalized_direction():
		if Input.is_action_pressed(&"sprint") and player.weapon.can_sprint:
			finished.emit("sprint")
		else:
			finished.emit("walk")
	_move(delta)
