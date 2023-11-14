class_name Player
extends CharacterBody3D


signal decal_requested(collision_info: Dictionary)

const MAX_X_ROTATION := deg_to_rad(80)
const DEFAULT_MAX_RECOIL_RANDOMNESS := 2.0
const BOB_FREQUENCY := 1.0  # determines how often footsteps happen
const BOB_AMPLITUDE := 0.06  # how far the camera will move

@export var acceleration := 4
@export var mouse_sentitivity := 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var direction := Vector3.ZERO
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var x_rot_before_shoot: float
var speed: int
var max_recoil_randomness := DEFAULT_MAX_RECOIL_RANDOMNESS
var rng := RandomNumberGenerator.new()
var bob_time := 0.0

# Nodes
@onready var fsm := $StateMachine as PlayerStateMachine
@onready var mesh_instance := $MeshInstance3D as MeshInstance3D
@onready var collision := $CollisionShape3D as CollisionShape3D
@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var remote_transform := $Head/Camera3D/RemoteTransform3D as RemoteTransform3D
@onready var anim_player := $AnimationPlayer as AnimationPlayer
@onready var hud := $Head/Camera3D/HUD as Hud
@onready var weapon := $Head/Camera3D/Weapon as Weapon


func _ready() -> void:
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# mouse movement (left and right)
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sentitivity))
		# camera x rotation (up and down)
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sentitivity))
		camera.rotation.x = clamp(camera.rotation.x, -MAX_X_ROTATION, MAX_X_ROTATION)


func _physics_process(delta: float) -> void:
	# apply gravity
	velocity.y -= gravity * delta
	# head bob animation
	bob_time += velocity.length() * delta if is_on_floor() else 0.0
	camera.position = _calculate_head_bob(bob_time)
	
	move_and_slide()


func _calculate_head_bob(time: float) -> Vector3:
	var camera_pos := Vector3.ZERO
	camera_pos.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	camera_pos.x = cos(time * BOB_FREQUENCY / 2.0) * BOB_AMPLITUDE
	
	return camera_pos


func _on_weapon_has_shot(spray_curve: Curve2D) -> void:
	# apply recoil
	var spray_position := spray_curve.get_point_position(weapon.heat)
	#var recoil_offset := Vector2(sign(spray_position.x), -sign(spray_position.y))
	#print("Spray pos: ", spray_position)
	#var rand_offset := rng.randf_range(-max_recoil_randomness, max_recoil_randomness)
	# rotate the camera to obtain a recoil effect
	camera.rotation.x += deg_to_rad(0.5)
	camera.rotation.x = clampf(camera.rotation.x, x_rot_before_shoot - deg_to_rad(5.0),
			x_rot_before_shoot + deg_to_rad(5.0))
	if not weapon.heat == weapon.max_heat:
		head.rotation.y += deg_to_rad(spray_position.x) * 0.025


func _on_weapon_decal_requested(collider_info: Dictionary) -> void:
	decal_requested.emit(collider_info)


func _on_weapon_shoot_started() -> void:
	x_rot_before_shoot = camera.rotation.x
	# Prevent the follow camera from following the main camera's vertical recoil.
	# This is done because the weapon will use it to project the ray used for the recoil pattern
	remote_transform.update_rotation = false


func _on_weapon_shoot_finished() -> void:
	var tween := create_tween()
	tween.tween_property(camera, "rotation:x", x_rot_before_shoot, weapon.fire_rate)
	remote_transform.update_rotation = true


func _on_state_machine_state_changed(states_stack: Array) -> void:
	hud.player_state_label.text = (states_stack[0] as State).name


func _on_weapon_state_changed(states_stack: Array) -> void:
	hud.weapon_state_label.text = (states_stack[0] as State).name


func _on_weapon_ammo_changed(ammo: int) -> void:
	hud.ammo_label.text = str(ammo)
