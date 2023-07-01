extends PlayerState


func enter() -> void:
	(owner as Player).speed = 0


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("crouch")
	return super(event)


func update(delta: float) -> void:
	if _get_normalized_direction():
		if Input.is_action_pressed("sprint"):
			finished.emit("sprint")
		else:
			finished.emit("walk")
	_move(delta)
