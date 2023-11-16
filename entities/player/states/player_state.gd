class_name PlayerState
extends State


@onready var player := owner as Player


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("ui_select") and player.is_on_floor():
		finished.emit("jump")
	return super(event)


func _get_normalized_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	return (player.head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func _move(delta: float) -> void:
	player.direction = _get_normalized_direction()
	player.velocity = player.velocity.lerp(player.direction * player.speed,
			player.acceleration * delta)
