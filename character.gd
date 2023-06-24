extends CharacterBody3D


@export var speed := 10
@export var acceleration := 4
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity := 9.8
@export var mouse_sentitivity := 0.15
@export var jump_power := 30

var camera_x_rotation := 0.0

@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var label := $Head/Camera3D/Label3D as Label3D


func _ready() -> void:
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sentitivity))
		var x_delta: float = event.relative.y * mouse_sentitivity
		# clamp camera x rotation to up and down
		var target_x_rotation := camera_x_rotation + x_delta
		if target_x_rotation > -90 and target_x_rotation < 90:
			camera.rotate_x(deg_to_rad(-x_delta))
			camera_x_rotation = target_x_rotation


func _physics_process(delta: float) -> void:
	label.text = str(Engine.get_frames_per_second())
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
	# apply gravity
#	velocity.y -= gravity * delta
	# jumping
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y += jump_power
	
	move_and_slide()
