extends PlayerState


func enter() -> void:
	(owner as Player).speed = 0


func update(delta: float) -> void:
	if _get_normalized_direction():
		if Input.is_action_pressed("sprint") and (owner as Player).fsm.can_sprint:
			finished.emit("sprint")
		else:
			finished.emit("walk")
	_move(delta)
