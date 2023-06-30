class_name Player
extends CharacterBody3D


signal has_shot(raycast: RayCast3D)

const MAX_X_ROTATION := 80  # degrees

@export var default_speed := 10
@export var sprint_speed := 15
@export var crouch_speed := 6
@export var acceleration := 4
@export var mouse_sentitivity := 0.15
@export var jump_power := 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var direction := Vector3.ZERO
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var camera_x_rotation := 0.0
var speed: int
var is_crouching := false:
	set = _set_is_crouching

@onready var fsm := $StateMachine as PlayerStateMachine
@onready var mesh_instance := $MeshInstance3D as MeshInstance3D
@onready var collision := $CollisionShape3D as CollisionShape3D
@onready var head := $Head as Node3D
@onready var camera := $Head/Camera3D as Camera3D
@onready var anim_player := $AnimationPlayer as AnimationPlayer
@onready var hud := $Head/Camera3D/HUD as Hud
@onready var raycast := $Head/Camera3D/RayCast3D as RayCast3D
@onready var weapon := $Head/Camera3D/Weapon as Weapon


func _ready() -> void:
	speed = default_speed
	# lock mouse to the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# mouse movement
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sentitivity))
		var x_delta: float = event.relative.y * mouse_sentitivity
		# clamp camera x rotation to up and down
		var target_x_rotation := camera_x_rotation + x_delta
		if target_x_rotation > -MAX_X_ROTATION and target_x_rotation < MAX_X_ROTATION:
			camera.rotate_x(deg_to_rad(-x_delta))
			camera_x_rotation = target_x_rotation


func _process(delta: float) -> void:
	# aiming
	if Input.is_action_pressed("ads"):
		weapon.aim(delta)
	else:
		weapon.un_aim(delta)
	# firing
	if Input.is_action_pressed("fire1"):
		if weapon.cur_ammo:
			weapon.shoot()
		else:
			weapon.reload()
	# reloading
	elif Input.is_action_just_pressed("reload"):
		weapon.reload()


func _physics_process(delta: float) -> void:
	# apply gravity
	velocity.y -= gravity * delta
	# jumping
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y += jump_power
	# crouching
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		if not is_crouching:
			anim_player.play("player/crouch")
			speed = crouch_speed
			is_crouching = true
		else:
			anim_player.play_backwards("player/crouch")
			speed = default_speed
			is_crouching = false
	# head bob animation
#	if direction != Vector3.ZERO:
#		anim_player.play("camera/head_bobbing")

	move_and_slide()


func _set_is_crouching(value: bool) -> void:
	is_crouching = value


func _on_weapon_has_shot() -> void:
	if raycast.get_collider():
		has_shot.emit(raycast)


func _on_weapon_has_reloaded() -> void:
	pass


func _on_state_machine_state_changed(states_stack) -> void:
	hud.state_label.text = (states_stack[0] as State).name
