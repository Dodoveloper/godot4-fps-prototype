class_name Weapon
extends Node3D


signal ads_toggled(enabled: bool)
signal has_shot(recoil_offset: Vector2)
signal state_changed(states_stack: Array)
signal ammo_changed(ammo: int)
signal heat_changed(value: int)
signal shoot_started()
signal shoot_finished()
signal decal_requested(collider_info: Dictionary)

const SWAY_TRESHOLD := 5
const SWAY_LERP := 5

@export var damage := 10
@export var fire_rate := 0.08
@export var mag_size := 30
@export var reload_time := 1.2
@export var weapon_range := 200
@export var vertical_kick_factor := 0.006
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
@export var screenshake_amount := 0.2

var cur_ammo: int = mag_size:
	set(value):
		cur_ammo = value
		ammo_changed.emit(cur_ammo)
var can_sprint := true
var is_player_walking := false  # TODO: consider adding a walk state
var mouse_movement: float
var spray_curve: Curve2D
var heat := 0:
	set(value):
		heat = min(value, max_heat)
		heat_changed.emit(heat)

@onready var heat_tween := create_tween()
# Nodes
@onready var fsm := $StateMachine as WeaponStateMachine
@onready var bullet_spawn := $AKM/BulletSpawn as Marker3D
@onready var camera := get_node(camera_path) as Camera3D
@onready var gun_fire := $GunFIre as AudioStreamPlayer
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	position = default_position
	
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


func is_mag_full() -> bool:
	return cur_ammo == mag_size


func check_hitscan_collision() -> void:
	var collision_pos := _get_camera_collision()
	var bullet_dir := (collision_pos - bullet_spawn.global_position).normalized()
	var query := PhysicsRayQueryParameters3D.create(bullet_spawn.global_position,
			collision_pos + bullet_dir*2)
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(query)
	
	if bullet_collision:
		decal_requested.emit(bullet_collision)
		
		var collider := bullet_collision["collider"] as Node
		if collider is Enemy:
			collider.destroy()


## Projects a ray from the weapon's muzzle to the camera center.
## The ray's length is the weapon's range.
## Returns the collision's position, if present, otherwise the ray's end position.
func _get_camera_collision() -> Vector3:
	var viewport_center := get_viewport().get_visible_rect().size / 2
	
	var ray_origin := camera.project_ray_origin(viewport_center)
	var recoil_offset := spray_curve.get_point_position(heat)
	var ray_end := ray_origin + camera.project_ray_normal(viewport_center + recoil_offset) \
			* weapon_range
	
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	
	return collision.position if not collision.is_empty() else ray_end


func _on_state_machine_state_changed(states_stack: Array) -> void:
	state_changed.emit(states_stack)
