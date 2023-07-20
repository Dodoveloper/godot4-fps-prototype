extends WeaponAimable


var can_shoot := true
var heat_increase_tween: Tween
var heat_decrease_tween: Tween

@onready var rng := RandomNumberGenerator.new()
@onready var fire_rate_timer := $FireRateTimer as Timer


func enter() -> void:
	# handle heat
	if heat_decrease_tween:
		heat_decrease_tween.kill()
	heat_increase_tween = create_tween()
	heat_increase_tween.tween_property(weapon, "heat", weapon.max_heat, 1.0)
	
	weapon.shoot_started.emit()


# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	# handle heat
	var decrease_duration := heat_increase_tween.get_total_elapsed_time()
	heat_increase_tween.kill()
	heat_decrease_tween = create_tween()
	heat_decrease_tween.tween_property(weapon, "heat", 0, decrease_duration / 2.0)
	
	weapon.shoot_finished.emit()


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_pressed("reload") and not weapon.is_mag_full():
		finished.emit("reload")
	return super(event)


func update(_delta: float) -> void:
	weapon.camera.add_trauma(0.05)
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
	weapon.has_shot.emit(weapon.spray_curve)
	# sound
	weapon.gun_fire.play()


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true
