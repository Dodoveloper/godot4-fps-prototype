extends PlayerState


@export var jump_power := 10


func enter() -> void:
	player.velocity.y += jump_power


func update(delta: float) -> void:
	if player.is_on_floor():
		if _get_normalized_direction():
			if Input.is_action_pressed("sprint") and player.weapon.can_sprint:
				finished.emit("sprint")
			else:
				finished.emit("walk")
		else:
			finished.emit("idle")
	_move(delta)
