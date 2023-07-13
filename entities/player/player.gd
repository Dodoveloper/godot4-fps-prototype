class_name Player
extends CharacterBody3D


signal has_shot(raycast: RayCast3D)

const MAX_X_ROTATION := deg_to_rad(80)

@export var acceleration := 4
@export var mouse_sentitivity := 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var direction := Vector3.ZERO
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var rotation_target = Vector2.ZERO
var x_rot_before_shoot: float
var speed: int

# Nodes
@onready var fsm := $StateMachine as PlayerStateMachine
@onready var mesh_instance := $MeshInstance3D as MeshInstance3D
@onready var collision := $CollisionShape3D as CollisionShape3D
@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var anim_player := $AnimationPlayer as AnimationPlayer
@onready var hud := $Head/Camera3D/HUD as Hud
@onready var raycast := $"%RayCast3D" as RayCast3D
@onready var weapon := $Head/Camera3D/Weapon as Weapon
# Variables
@onready var default_raycast_target_pos := raycast.target_position


func _ready() -> void:
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# mouse movement (left and right)
		rotation_target.y = deg_to_rad(-event.relative.x * mouse_sentitivity)
		# camera x rotation (up and down)
		rotation_target.x = deg_to_rad(-event.relative.y * mouse_sentitivity)


func _physics_process(delta: float) -> void:
	var actual_rotation = Vector2.ZERO.lerp(rotation_target, 30 * delta)
	rotation_target -= actual_rotation
	head.rotate_y(actual_rotation.y)
	camera.rotate_x(actual_rotation.x)
	camera.rotation.x = clamp(camera.rotation.x, -MAX_X_ROTATION, MAX_X_ROTATION)
	# apply gravity
	velocity.y -= gravity * delta
	# head bob animation
#	if direction != Vector3.ZERO:
#		anim_player.play("camera/head_bobbing")
	
	move_and_slide()


func _on_weapon_has_shot(spray_curve: Curve2D) -> void:
	# apply recoil
	var count: int = min(weapon.heat, weapon.max_heat)
	var spray_position := spray_curve.get_point_position(count)
	var recoil_offset := Vector3(spray_position.x, -spray_position.y, 0)
	print("Recoil offset: ", recoil_offset)
	raycast.target_position.x = recoil_offset.x
	raycast.target_position.y = recoil_offset.y
	rotation_target.x += recoil_offset.y * 0.006
	# decal code
	if raycast.get_collider():
		has_shot.emit(raycast)


func _on_weapon_heat_changed(value: int) -> void:
	if value == 0:
		raycast.target_position = default_raycast_target_pos
		raycast.force_raycast_update()


func _on_weapon_shoot_started() -> void:
	x_rot_before_shoot = camera.rotation.x


func _on_weapon_shoot_finished() -> void:
	var tween := create_tween()
	tween.tween_property(camera, "rotation:x", x_rot_before_shoot, weapon.fire_rate)


func _on_state_machine_state_changed(states_stack: Array) -> void:
	hud.player_state_label.text = (states_stack[0] as State).name


func _on_weapon_state_changed(states_stack: Array) -> void:
	hud.weapon_state_label.text = (states_stack[0] as State).name
