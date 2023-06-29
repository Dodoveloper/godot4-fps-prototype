extends PlayerState


signal exited(wait_time: float, time_left: float)  # used for sprint cooldown

@export var sprint_speed := 15

@onready var duration_timer := $Duration as Timer


func enter() -> void:
	(owner as Player).speed = sprint_speed
	(owner as Player).weapon.is_sprinting = true
	duration_timer.start()


func exit() -> void:
	(owner as Player).weapon.is_sprinting = false
	exited.emit(duration_timer.wait_time, duration_timer.time_left)
	duration_timer.stop()


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("crouch"):
		finished.emit("crouch")
	elif event.is_action_released("sprint"):
		finished.emit("walk")
	return super(event)


func update(delta: float) -> void:
	if not _get_normalized_direction():
		finished.emit("idle")
	_move(delta)


func _on_duration_timeout() -> void:
	finished.emit("walk")
