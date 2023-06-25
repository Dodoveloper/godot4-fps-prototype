extends CharacterBody3D


@export var health := 100

var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var target: Node3D

@onready var body_mesh := $Body as MeshInstance3D


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# apply gravity
	velocity.y -= gravity * delta
	if target:
		look_at(target.global_transform.origin)
	move_and_slide()


func _on_detector_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		target = body
		(body_mesh.get_active_material(0) as StandardMaterial3D).albedo_color = Color.RED


func _on_detector_area_3d_body_exited(body: Node3D) -> void:
	if body is Character:
		target = null
		(body_mesh.get_active_material(0) as StandardMaterial3D).albedo_color = Color.GREEN
