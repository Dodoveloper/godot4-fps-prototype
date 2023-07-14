class_name Weapon
extends Node3D


signal ads_toggled(enabled: bool)
signal has_shot(spray_curve: Curve2D)
signal state_changed(states_stack: Array)
signal ammo_changed(ammo: int)
signal heat_changed(value: int)
signal shoot_started()
signal shoot_finished()

const SWAY_TRESHOLD := 5
const SWAY_LERP := 5

@export var damage := 10
@export var fire_rate := 0.08
@export var mag_size := 30
@export var reload_time := 1.2
@export var vertical_kick_factor := 0.006
@export var raycast_path: NodePath
@export var camera_path: NodePath
@export var ads_position: Vector3
@export var default_position: Vector3
@export var ads_fov := 55.0
@export var default_fov := 75.0
@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_default: Vector3
@export var spray_scene: PackedScene
@export var max_heat := 13

var cur_ammo := mag_size:
	set(value):
		cur_ammo = value
		ammo_changed.emit(cur_ammo)
var can_sprint := true
var is_player_walking := false  # TODO: consider adding a walk state
var mouse_movement: float
var spray_curve: Curve2D
var heat := 0:
	set(value):
		heat = value
		emit_signal("heat_changed", heat)

@onready var heat_tween := create_tween()
# Nodes
@onready var fsm := $StateMachine as WeaponStateMachine
@onready var raycast := get_node(raycast_path) as RayCast3D
@onready var camera := get_node(camera_path) as Camera3D
@onready var gun_fire := $GunFIre as AudioStreamPlayer
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	heat_tween.stop()
	if spray_scene != null:
		var spray := spray_scene.instantiate() as Path2D
		spray_curve = spray.curve


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


func set_sprinting(value: bool) -> void:
	anim_player.play("sprinting" if value else "holding", 0.2)


func is_mag_full() -> bool:
	return cur_ammo == mag_size


func check_collision() -> void:
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.queue_free()


func _on_state_machine_state_changed(states_stack: Array) -> void:
	state_changed.emit(states_stack)
