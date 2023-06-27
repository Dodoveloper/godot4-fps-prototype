class_name Weapon
extends Node3D


signal ads_toggled(enabled: bool)
signal has_shot()

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
@export var sway_normal: Vector3

var cur_ammo := mag_size:
	set(value):
		cur_ammo = value
		ammo_label.text = str(value)
var can_fire := true
var is_reloading := false
var is_sprinting := false:
	set = _set_is_sprinting
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
			rotation = rotation.lerp(sway_normal, SWAY_LERP * delta)
	# states
	if not is_reloading:
		if Input.is_action_pressed("ads"):
			position = position.lerp(ads_position, ADS_LERP_SPEED * delta)
			camera.fov = lerpf(camera.fov, ads_fov, ADS_LERP_SPEED * delta)
			ads_toggled.emit(true)
		else:
			position = position.lerp(default_position, ADS_LERP_SPEED * delta)
			camera.fov = lerpf(camera.fov, default_fov, ADS_LERP_SPEED * delta)
			ads_toggled.emit(false)
	if Input.is_action_pressed("fire1") and can_fire and not is_reloading:
		if cur_ammo:
			_shoot()
		else:
			_reload()
	elif Input.is_action_just_pressed("reload") and not is_reloading and not is_sprinting:
		_reload()


func _shoot() -> void:
	can_fire = false
	cur_ammo -= 1
	_check_collision()
	fire_rate_timer.start(fire_rate)
	anim_player.play("firing")
	has_shot.emit()


func _reload() -> void:
	if cur_ammo == mag_size:
		return
	print("Reloading")
	is_reloading = true
	reload_timer.start(reload_time)
	anim_player.play("reloading")


func _check_collision() -> void:
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.queue_free()
			print("Killed ", collider.name)


func _set_is_sprinting(value: bool) -> void:
	is_sprinting = value
	can_fire = not is_sprinting
	anim_player.play("sprinting" if is_sprinting else "holding")


func _on_fire_rate_timer_timeout() -> void:
	can_fire = true


func _on_reload_timer_timeout() -> void:
	print("Reloaded")
	is_reloading = false
	cur_ammo = mag_size
