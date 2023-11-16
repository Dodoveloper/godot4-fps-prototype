class_name PlayerState
extends State


@onready var player := owner as Player


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed(&"ui_select") and player.is_on_floor():
		finished.emit("jump")
	return super(event)


func _get_normalized_direction() -> Vector3:
	player.input_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	return (player.head.transform.basis * Vector3(player.input_dir.x, 0, player.input_dir.y)).normalized()


func _move(delta: float) -> void:
	player.velocity = player.velocity.lerp(_get_normalized_direction() * player.speed,
			player.acceleration * delta)
