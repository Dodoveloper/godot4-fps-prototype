class_name Player
extends CharacterBody3D


signal has_shot(raycast: RayCast3D)

const MAX_X_ROTATION := 80  # degrees

@export var default_speed := 10
@export var sprint_speed := 20
@export var acceleration := 4
@export var mouse_sentitivity := 0.15
@export var jump_power := 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var camera_x_rotation := 0.0
var speed: int
var can_sprint := true

@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var cam_anim_player := $Head/Camera3D/AnimationPlayer as AnimationPlayer
@onready var hud := $Head/Camera3D/HUD as Hud
@onready var raycast := $Head/Camera3D/RayCast3D as RayCast3D
@onready var sprint_timer := $SprintTimer as Timer
@onready var sprint_cooldown := $SprintCooldown as Timer


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
	if Input.is_action_just_pressed("sprint"):
		sprint_timer.start()
	elif Input.is_action_just_released("sprint"):
		sprint_cooldown.start(sprint_timer.time_left)
		sprint_timer.stop()


func _physics_process(delta: float) -> void:
	speed = default_speed
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
	# sprinting
	if Input.is_action_pressed("sprint") and can_sprint:
		speed = sprint_speed
	# jumping
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y += jump_power
	# handle movement and acceleration
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	# head bob animation
	if direction != Vector3.ZERO:
		cam_anim_player.play("head_bobbing")

	move_and_slide()


func _on_weapon_has_shot() -> void:
	if raycast.get_collider():
		has_shot.emit(raycast)


func _on_sprint_timer_timeout() -> void:
	can_sprint = false
	sprint_cooldown.start(sprint_timer.wait_time)
	print("sprint timeout")
	


func _on_sprint_cooldown_timeout() -> void:
	can_sprint = true
	print("sprint cooldown timeout")
