class_name PlayerState
extends State


@onready var player := owner as Player


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("ui_select") and player.is_on_floor():
		finished.emit("jump")
	return super(event)


func _get_normalized_direction() -> Vector3:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= player.head.transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += player.head.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= player.head.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += player.head.transform.basis.x
	return direction.normalized()


func _move(delta: float) -> void:
	var direction := _get_normalized_direction()
	player.velocity = player.velocity.lerp(
			direction * player.speed,
			player.acceleration * delta)
