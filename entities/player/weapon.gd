class_name Weapon
extends Node3D


signal ads_toggled(enabled: bool)
signal has_shot()
signal has_reloaded()

const ADS_LERP_SPEED := 20
const SWAY_TRESHOLD := 5
const SWAY_LERP := 5

@export var damage := 10
@export var fire_rate := 0.08
@export var mag_size := 30
@export var reload_time := 1.2
@export var raycast_path: NodePath
@export var camera_path: NodePath
@export var default_position: Vector3
@export var ads_position: Vector3
@export var default_fov := 75.0
@export var ads_fov := 55.0
@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_default: Vector3

var cur_ammo := mag_size:
	set(value):
		cur_ammo = value
		ammo_label.text = str(cur_ammo)
var can_aim := true
var can_shoot := true
var can_reload := false
var is_aiming := false:
	set(value):
		is_aiming = value
		ads_toggled.emit(is_aiming)
var is_reloading := false:
	set(value):
		is_reloading = value
		can_shoot = not is_reloading
		can_aim = not is_reloading
var is_sprinting := false:
	set(value):
		is_sprinting = value
		print("sprinting: ", is_sprinting)
		can_shoot = not is_sprinting
		can_aim = not is_sprinting
		can_reload = not is_sprinting
		anim_player.play("sprinting" if is_sprinting else "holding", 0.2)
var mouse_movement: float

@onready var raycast := get_node(raycast_path) as RayCast3D
@onready var camera := get_node(camera_path) as Camera3D
@onready var ammo_label := $MeshInstance3D/AmmoLabel as Label3D
@onready var fire_rate_timer := $FireRateTimer as Timer
@onready var reload_timer := $ReloadTimer as Timer
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = -event.relative.x


func _process(delta: float) -> void:
	# sway
	if mouse_movement != null:
		if mouse_movement > SWAY_TRESHOLD:
			rotation = rotation.lerp(sway_left, SWAY_LERP * delta)
		elif mouse_movement < -SWAY_TRESHOLD:
			rotation = rotation.lerp(sway_right, SWAY_LERP * delta)
		else:
			rotation = rotation.lerp(sway_default, SWAY_LERP * delta)


func aim(delta: float) -> void:
	if not can_aim:
		return
	position = position.lerp(ads_position, ADS_LERP_SPEED * delta)
	camera.fov = lerpf(camera.fov, ads_fov, ADS_LERP_SPEED * delta)
	is_aiming = true


func un_aim(delta: float) -> void:
	position = position.lerp(default_position, ADS_LERP_SPEED * delta)
	camera.fov = lerpf(camera.fov, default_fov, ADS_LERP_SPEED * delta)
	is_aiming = false


func shoot() -> void:
	if not can_shoot:
		return
	can_shoot = false
	cur_ammo -= 1
	_check_collision()
	fire_rate_timer.start(fire_rate)
	anim_player.play("firing")
	has_shot.emit()


func reload() -> void:
	if cur_ammo == mag_size or not can_reload:
		return
	is_reloading = true
	print("reloading: ", is_reloading)
	reload_timer.start(reload_time)
	anim_player.play("reloading")


func _check_collision() -> void:
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.queue_free()


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true


func _on_reload_timer_timeout() -> void:
	is_reloading = false
	cur_ammo = mag_size
	has_reloaded.emit()
