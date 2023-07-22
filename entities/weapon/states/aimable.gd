class_name WeaponAimable
extends State


const ADS_LERP_SPEED := 20

@onready var weapon: Weapon = owner


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("sprint"):
		finished.emit("sprint")
	
	return super(event)


func update(delta: float) -> void:
	if Input.is_action_pressed("ads"):
		weapon.ads_toggled.emit(true)
#		weapon.position = weapon.position.lerp(weapon.ads_position,
#				ADS_LERP_SPEED * delta)
		weapon.camera.fov = lerpf(weapon.camera.fov, weapon.ads_fov,
				ADS_LERP_SPEED * delta)
	else:
		weapon.ads_toggled.emit(false)
#		weapon.position = weapon.position.lerp(weapon.default_position,
#				ADS_LERP_SPEED * delta)
		weapon.camera.fov = lerpf(weapon.camera.fov, weapon.default_fov,
				ADS_LERP_SPEED * delta)
