extends State


const ADS_LERP_SPEED := 20

@export var ads_position: Vector3
@export var default_position: Vector3
@export var ads_fov := 55.0
@export var default_fov := 75.0

@onready var weapon: Weapon = owner


func enter() -> void:
	weapon.ads_toggled.emit(true)


func exit() -> void:
	weapon.ads_toggled.emit(false)


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("fire1"):
		finished.emit("shootaim" if (owner as Weapon).cur_ammo else "reload")
	elif event.is_action_pressed("reload"):
		finished.emit("reload")
	return super(event)


func update(delta: float) -> void:
	if Input.is_action_pressed("ads"):
		weapon.position = weapon.position.lerp(ads_position, ADS_LERP_SPEED * delta)
		weapon.camera.fov = lerpf(weapon.camera.fov, ads_fov, ADS_LERP_SPEED * delta)
	else:
		weapon.position = weapon.position.lerp(default_position, ADS_LERP_SPEED * delta)
		weapon.camera.fov = lerpf(weapon.camera.fov, default_fov, ADS_LERP_SPEED * delta)
		if weapon.position.is_equal_approx(default_position) \
				and is_equal_approx(weapon.camera.fov, default_fov):
			finished.emit("idle")

