extends PlayerState


func enter() -> void:
	(owner as Player).speed = 0


func update(delta: float) -> void:
	if _get_normalized_direction():
		finished.emit("sprint" if Input.is_action_pressed("sprint") else "walk")
	_move(delta)
