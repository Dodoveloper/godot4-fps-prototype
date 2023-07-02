extends WeaponAimable


var can_shoot := true

@onready var rng := RandomNumberGenerator.new()
@onready var fire_rate_timer := $FireRateTimer as Timer


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("reload") and not weapon.is_mag_full():
		finished.emit("reload")
	return super(event)


func update(_delta: float) -> void:
	if Input.is_action_pressed("fire1"):
		if weapon.cur_ammo:
			_shoot()
		else:
			finished.emit("reload")
	else:
		finished.emit("idle" if weapon.cur_ammo else "reload")


func _shoot() -> void:
	if not can_shoot:
		return
	can_shoot = false
	weapon.cur_ammo -= 1
	weapon.check_collision()
	fire_rate_timer.start(weapon.fire_rate)
	weapon.anim_player.play("firing")
	# recoil
	var horizontal_recoil := rng.randfn(0.0, weapon.max_horizontal_recoil)
	var vertical_recoil := rng.randfn(0.0, weapon.max_vertical_recoil)
	weapon.has_shot.emit(horizontal_recoil, vertical_recoil)


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true
