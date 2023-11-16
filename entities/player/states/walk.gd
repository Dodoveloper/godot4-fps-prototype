extends PlayerState


@export var default_speed := 10


func enter() -> void:
	player.speed = default_speed
	player.weapon.recoil_randomness *= 1.5
	player.weapon.is_player_walking = true


func exit() -> void:
	player.weapon.is_player_walking = false


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("crouch")
	elif event.is_action_pressed("sprint") and player.weapon.can_sprint:
		finished.emit("sprint")
	return super(event)


func update(delta: float) -> void:
	if not _get_normalized_direction():
		finished.emit("idle")
	_move(delta)
