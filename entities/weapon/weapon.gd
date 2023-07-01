class_name Weapon
extends Node3D


signal ads_toggled(enabled: bool)
signal has_shot()
signal state_changed(states_stack: Array)

const SWAY_TRESHOLD := 5
const SWAY_LERP := 5

@export var damage := 10
@export var fire_rate := 0.08
@export var mag_size := 30
@export var reload_time := 1.2
@export var raycast_path: NodePath
@export var camera_path: NodePath
@export var ads_position: Vector3
@export var default_position: Vector3
@export var ads_fov := 55.0
@export var default_fov := 75.0
@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_default: Vector3

var cur_ammo := mag_size:
	set(value):
		cur_ammo = value
		ammo_label.text = str(cur_ammo)
var can_sprint := true
var is_sprinting := false:
	set(value):
		is_sprinting = value
		anim_player.play("sprinting", 0.2)
var mouse_movement: float

@onready var raycast := get_node(raycast_path) as RayCast3D
@onready var camera := get_node(camera_path) as Camera3D
@onready var ammo_label := $MeshInstance3D/AmmoLabel as Label3D
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


func is_mag_full() -> bool:
	return cur_ammo == mag_size


func check_collision() -> void:
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.queue_free()


func _on_state_machine_state_changed(states_stack: Array) -> void:
	state_changed.emit(states_stack)
