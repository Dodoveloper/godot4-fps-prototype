extends PlayerState


@export var default_speed := 10


func enter() -> void:
	(owner as Player).speed = default_speed


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("crouch")
	elif event.is_action_pressed("sprint") and (owner as Player).fsm.can_sprint:
		finished.emit("sprint")
	return super(event)


func update(delta: float) -> void:
	if not _get_normalized_direction():
		finished.emit("idle")
	_move(delta)
