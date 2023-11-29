class_name Enemy
extends CharacterBody3D


signal destroyed

@export var health := 100
@export var speed := 7.5

var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var target: Node3D

@onready var space_state := get_world_3d().direct_space_state
@onready var body_mesh := $Body as MeshInstance3D


func _ready() -> void:
	# ensure the material is unique for each instance
	var duplicated_material := body_mesh.get_active_material(0).duplicate()
	body_mesh.set_surface_override_material(0, duplicated_material)


func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	# apply gravity
	velocity.y -= gravity * delta
	# look at the player while checking if there is a line of sight
	if target:
		var result := space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
				global_transform.origin, target.global_transform.origin))
		if result.collider is Player:
			look_at(target.global_transform.origin)
			_set_body_albedo(Color.RED)
			# move to target
			direction = (target.transform.origin - transform.origin).normalized()
		else:
			_set_body_albedo(Color.GREEN)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()


func destroy() -> void:
	destroyed.emit()
	queue_free()


func _set_body_albedo(color: Color) -> void:
	(body_mesh.get_active_material(0) as StandardMaterial3D).albedo_color = color


func _on_detector_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		target = body
		_set_body_albedo(Color.RED)


func _on_detector_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		target = null
		_set_body_albedo(Color.GREEN)
