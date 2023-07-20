extends State


func enter() -> void:
	(owner as Weapon).anim_player.play("sprinting", 0.2)


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_released("sprint"):
		finished.emit("idle")
	
	return super(event)
