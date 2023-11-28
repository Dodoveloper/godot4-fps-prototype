extends State


@onready var weapon: Weapon = owner


func enter() -> void:
	(weapon.get_node("AnimationPlayer") as AnimationPlayer).play("idling", 0.2)


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed(&"fire1"):
		finished.emit("shoot" if weapon.cur_ammo else "reload")
	elif event.is_action_pressed(&"reload") and not weapon.is_mag_full():
		finished.emit("reload")
	
	return super(event)
