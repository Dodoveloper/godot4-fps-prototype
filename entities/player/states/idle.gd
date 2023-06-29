extends PlayerState


func enter() -> void:
	(owner as Player).speed = 0


func update(delta: float) -> void:
	if get_normalized_direction():
		finished.emit("walk" if not Input.is_action_pressed("sprint") else "sprint")
