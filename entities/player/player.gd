class_name Player
extends CharacterBody3D


signal decal_requested(collision_info: Dictionary)
signal impact_requested(pos: Vector3, weapon_pos: Vector3)

const MAX_X_ROTATION := deg_to_rad(80)

@export var acceleration := 10
@export var mouse_sentitivity := 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var direction := Vector3.ZERO
var speed: int
var x_rot_before_shoot: float

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
	# bob animation
	if is_on_floor():
		weapon.apply_bob(velocity, delta)
	
	move_and_slide()


func _on_weapon_has_shot(_recoil_offset: Vector2) -> void:
	# rotate the camera to obtain a recoil effect
	camera.rotation.x += deg_to_rad(0.5)
	camera.rotation.x = clampf(camera.rotation.x,
			x_rot_before_shoot - deg_to_rad(weapon.max_x_recoil_rotation),
			x_rot_before_shoot + deg_to_rad(weapon.max_x_recoil_rotation))
	# FIXME: horizontal cam recoil
	#camera.rotation.y += deg_to_rad(recoil_offset.x) * 0.01
	# camera screenshake
	camera.add_trauma(weapon.screenshake_amount)


func _on_weapon_shoot_started() -> void:
	x_rot_before_shoot = camera.rotation.x
	# Prevent the follow camera from following the main camera's vertical recoil.
	# This is done because the weapon will use it to project the ray used for the recoil pattern
	remote_transform.update_rotation = false


func _on_weapon_shoot_finished() -> void:
	var tween := create_tween()
	tween.tween_property(camera, ^"rotation:x", x_rot_before_shoot, weapon.fire_rate)
	remote_transform.update_rotation = true


func _on_weapon_decal_requested(collider_info: Dictionary) -> void:
	decal_requested.emit(collider_info)


func _on_weapon_impact_requested(pos: Vector3, weapon_pos: Vector3) -> void:
	impact_requested.emit(pos, weapon_pos)


func _on_state_machine_state_changed(states_stack: Array) -> void:
	hud.player_state_label.text = (states_stack[0] as State).name


func _on_weapon_state_changed(states_stack: Array) -> void:
	hud.weapon_state_label.text = (states_stack[0] as State).name


func _on_weapon_ammo_changed(ammo: int) -> void:
	hud.ammo_label.text = str(ammo)
