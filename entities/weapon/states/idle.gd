extends WeaponAimable


func enter() -> void:
	(owner as Weapon).get_node("AnimationPlayer").play("holding")


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("fire1"):
		finished.emit("shoot" if (owner as Weapon).cur_ammo else "reload")
	elif event.is_action_pressed("reload") and not weapon.is_mag_full():
		finished.emit("reload")
	return super(event)
