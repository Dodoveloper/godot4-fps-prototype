class_name Weapon
extends Node3D


signal has_shot(recoil_offset: Vector2)
signal state_changed(states_stack: Array)
signal ammo_changed(ammo: int)
signal heat_changed(value: int)
signal decal_requested(collider_info: Dictionary)
signal impact_requested(pos: Vector3, weapon_pos: Vector3)

const DEFAULT_RECOIL_RANDOMNESS := 1.0

@export var damage := 10
@export var fire_rate := 0.08
@export var mag_size := 30
@export var reload_time := 1.2
@export var weapon_range := 200
@export var camera_path: NodePath
@export var spray_scene: PackedScene
@export var max_heat := 13
@export var screenshake_amount := 0.2
@export var max_x_recoil_rotation := 5.0  # degrees
@export var sway_amount := 0.015
@export var tilt_amount := 0.05
@export var default_position: Vector3

var cur_ammo: int = mag_size:
	set(value):
		cur_ammo = value
		ammo_changed.emit(cur_ammo)
var can_sprint := true
var mouse_movement: Vector2
var spray_curve: Curve2D
var heat := 0:
	set(value):
		heat = min(value, max_heat)
		heat_changed.emit(heat)
var rng := RandomNumberGenerator.new()
var recoil_randomness := DEFAULT_RECOIL_RANDOMNESS
var shot_index := 0:
	set(value):
		shot_index = min(value, mag_size - 1)
var bob_frequency := 0.01  # can be used to determine how often footsteps happen
var bob_amplitude := 0.01

# Nodes
@onready var fsm := $StateMachine as WeaponStateMachine
@onready var model := $Model as Node3D
@onready var bullet_spawn := $Model/BulletSpawn as Marker3D
@onready var camera := get_node(camera_path) as Camera3D
@onready var weapon_mesh: MeshInstance3D = $Model/RootNode/Armature/Skeleton3D/Mesh
@onready var muzzle_flash: GPUParticles3D = $Model/BulletSpawn/MuzzleFlash
@onready var tracer: MeshInstance3D = $Model/BulletSpawn/Tracer
@onready var gun_fire := $GunFIre as AudioStreamPlayer
@onready var anim_player := $AnimationPlayer as AnimationPlayer
# Other variables
@onready var heat_tween := create_tween()
@onready var tracer_position := tracer.position


func _ready() -> void:
	position = default_position
	heat_tween.stop()
	# set the camera FOV to the model shader
	weapon_mesh.viewmodel_fov = camera.fov
	
	if spray_scene != null:
		var spray := spray_scene.instantiate() as Path2D
		spray_curve = spray.curve


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func _physics_process(delta: float) -> void:
	_apply_sway(delta)


func is_mag_full() -> bool:
	return cur_ammo == mag_size


func apply_bob(velocity: Vector3, delta: float) -> void:
	if velocity.length() < 1.0:
		position.y = lerp(position.y, default_position.y, 10 * delta)
		position.x = lerp(position.x, default_position.x, 10 * delta)
	else:
		position.y = lerp(position.y,
				default_position.y + sin(Time.get_ticks_msec() * bob_frequency) * bob_amplitude,
				10 * delta)
		position.x = lerp(position.x,
				default_position.x + sin(Time.get_ticks_msec() * bob_frequency / 2.0) * bob_amplitude,
				10 * delta)


func tilt(velocity: Vector3, delta: float) -> void:
	# horizontal tilt
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	rotation.z = lerp(rotation.z, -input_dir.x * tilt_amount, 5 * delta)
	# vertical tilt
	rotation.x = lerp(rotation.x, -velocity.y * tilt_amount, 5 * delta)


func check_hitscan_collision() -> void:
	var collision_pos := _get_camera_collision()
	var bullet_dir := bullet_spawn.global_position.direction_to(collision_pos)
	var query := PhysicsRayQueryParameters3D.create(bullet_spawn.global_position,
			collision_pos + bullet_dir*2)
	var bullet_collision := get_world_3d().direct_space_state.intersect_ray(query)
	
	if bullet_collision:
		decal_requested.emit(bullet_collision)
		impact_requested.emit(collision_pos, bullet_spawn.global_position)
		
		var collider := bullet_collision["collider"] as Node
		if collider is Enemy:
			collider.take_damage(damage)


## Projects a ray from the weapon's muzzle to the camera center.
## The ray's length is the weapon's range.
## Returns the collision's position, if present, otherwise the ray's end position.
func _get_camera_collision() -> Vector3:
	var viewport_center := get_viewport().get_visible_rect().size / 2
	
	var ray_origin := camera.project_ray_origin(viewport_center)
	var recoil_offset := spray_curve.get_point_position(shot_index)  # point on the spray pattern
	var max_spray := recoil_randomness * heat  # higher heat == higher spread
	var rand_spray := Vector2(rng.randf_range(-max_spray, max_spray),
			rng.randf_range(-max_spray, max_spray))
	var ray_end := ray_origin + camera.project_ray_normal(
			viewport_center + recoil_offset + rand_spray) * weapon_range
	
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	
	return collision.position if not collision.is_empty() else ray_end


func _apply_sway(delta: float) -> void:
	# make it go back to its default position
	mouse_movement = lerp(mouse_movement, Vector2.ZERO, 10 * delta)
	rotation.x = lerp(rotation.x, mouse_movement.y * sway_amount, 10 * delta)
	rotation.y = lerp(rotation.y, mouse_movement.x * sway_amount, 10 * delta)


func _on_state_machine_state_changed(states_stack: Array) -> void:
	state_changed.emit(states_stack)
