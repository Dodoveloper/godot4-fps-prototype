extends State


func enter() -> void:
	(owner as Weapon).get_node("AnimationPlayer").play("holding")


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("fire1"):
		finished.emit("shoot" if (owner as Weapon).cur_ammo else "reload")
	elif event.is_action_pressed("ads"):
		finished.emit("aim")
	elif event.is_action_pressed("reload"):
		finished.emit("reload")
	return super(event)
