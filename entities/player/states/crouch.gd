extends PlayerState


@export var crouch_speed := 6


func enter() -> void:
	(owner as Player).anim_player.play("player/crouch")
	(owner as Player).speed = crouch_speed


func exit() -> void:
	(owner as Player).anim_player.play_backwards("player/crouch")


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("idle" if not _get_normalized_direction() else "walk")
	elif event.is_action_pressed("sprint"):
		finished.emit("sprint")
	return super(event)


func update(delta: float) -> void:
	_move(delta)
