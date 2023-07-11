class_name Player
extends CharacterBody3D


signal has_shot(raycast: RayCast3D)

const MAX_X_ROTATION := 80  # degrees

@export var acceleration := 4
@export var mouse_sentitivity := 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var direction := Vector3.ZERO
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var camera_x_rotation := 0.0
var speed: int

# Nodes
@onready var fsm := $StateMachine as PlayerStateMachine
@onready var mesh_instance := $MeshInstance3D as MeshInstance3D
@onready var collision := $CollisionShape3D as CollisionShape3D
@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var anim_player := $AnimationPlayer as AnimationPlayer
@onready var hud := $Head/Camera3D/HUD as Hud
@onready var raycast := $Head/Camera3D/RayCast3D as RayCast3D
@onready var weapon := $Head/Camera3D/Weapon as Weapon
# Variables
@onready var default_raycast_rotation := raycast.rotation


func _ready() -> void:
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# mouse movement (left and right)
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sentitivity))
		var x_delta: float = event.relative.y * mouse_sentitivity
		# camera x rotation (up and down, clamped)
		var target_x_rotation := camera_x_rotation + x_delta
		if target_x_rotation > -MAX_X_ROTATION and target_x_rotation < MAX_X_ROTATION:
			camera.rotate_x(deg_to_rad(-x_delta))
			camera_x_rotation = target_x_rotation


func _physics_process(delta: float) -> void:
	# apply gravity
	velocity.y -= gravity * delta
	# head bob animation
#	if direction != Vector3.ZERO:
#		anim_player.play("camera/head_bobbing")
	
	move_and_slide()


func _on_weapon_has_shot(spray_curve: Curve2D, _cur_ammo: int) -> void:
	# apply recoil
	var count: int = min(weapon.heat, weapon.max_heat)
	var spray_position := spray_curve.get_point_position(count)
	var recoil_offset := Vector3(spray_position.x, -spray_position.y, 0) / 500.0
	print("Recoil offset: ", recoil_offset)
	head.rotate_y(recoil_offset.x)
	camera.rotate_x(recoil_offset.y)
	# decal code
	if raycast.get_collider():
		has_shot.emit(raycast)


func _on_weapon_heat_changed(value: int) -> void:
	if value == 0:
#		head.rotation.y = 0.0
#		head.force_update_transform()
		camera.rotation.x = 0.0
		camera.force_update_transform()
		print("Resetting head and cam rotation to %.2f and %.2f" \
				% [head.rotation.y, camera.rotation.x])


func _on_state_machine_state_changed(states_stack: Array) -> void:
	hud.player_state_label.text = (states_stack[0] as State).name


func _on_weapon_state_changed(states_stack: Array) -> void:
	hud.weapon_state_label.text = (states_stack[0] as State).name
