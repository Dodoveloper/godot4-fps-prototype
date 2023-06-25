class_name Player
extends CharacterBody3D


const MAX_X_ROTATION := 80  # degrees

@export var speed := 10
@export var acceleration := 4
@export var mouse_sentitivity := 0.15
@export var jump_power := 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var camera_x_rotation := 0.0

@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var hud := $Head/Camera3D/HUD as Hud


func _ready() -> void:
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sentitivity))
		var x_delta: float = event.relative.y * mouse_sentitivity
		# clamp camera x rotation to up and down
		var target_x_rotation := camera_x_rotation + x_delta
		if target_x_rotation > -MAX_X_ROTATION and target_x_rotation < MAX_X_ROTATION:
			camera.rotate_x(deg_to_rad(-x_delta))
			camera_x_rotation = target_x_rotation


func _physics_process(delta: float) -> void:
	# apply gravity
	velocity.y -= gravity * delta
	# get the input direction
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= head.transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += head.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= head.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head.transform.basis.x
	direction = direction.normalized()
	# handle movement and acceleration
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	# jumping
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y += jump_power

	move_and_slide()
