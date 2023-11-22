class_name PlayerState
extends State


@onready var player := owner as Player


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed(&"ui_select") and player.is_on_floor():
		finished.emit("jump")
	
	return super(event)


func _move(delta: float) -> void:
	# lerp the direction to get some acceleration when moving/stopping
	player.direction = lerp(player.direction, _get_normalized_direction(), player.acceleration * delta)
	
	if player.direction:
		player.velocity.x = player.direction.x * player.speed
		player.velocity.z = player.direction.z * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed)
		player.velocity.z = move_toward(player.velocity.z, 0.0, player.speed)


func _get_normalized_direction() -> Vector3:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	return (player.head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
