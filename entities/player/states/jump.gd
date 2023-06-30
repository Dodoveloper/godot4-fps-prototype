extends PlayerState


@export var jump_power := 10


func enter() -> void:
	(owner as Player).velocity.y += jump_power


func update(delta: float) -> void:
	if (owner as Player).is_on_floor():
		if _get_normalized_direction():
			if Input.is_action_pressed("sprint"):
				finished.emit("sprint")
			else:
				finished.emit("walk")
		else:
			finished.emit("idle")
	_move(delta)
