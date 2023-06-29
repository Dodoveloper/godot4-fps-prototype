class_name PlayerState
extends State


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("ui_select") and (owner as Player).is_on_floor():
		finished.emit("jump")
	return super(event)


func _get_normalized_direction() -> Vector3:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= (owner as Player).head.transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += (owner as Player).head.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= (owner as Player).head.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += (owner as Player).head.transform.basis.x
	return direction.normalized()


func _move(delta: float) -> void:
	var direction := _get_normalized_direction()
	(owner as Player).velocity = (owner as Player).velocity.lerp(
			direction * (owner as Player).speed,
			(owner as Player).acceleration * delta)
