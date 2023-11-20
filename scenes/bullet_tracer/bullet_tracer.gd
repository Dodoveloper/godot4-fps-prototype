class_name BulletTracer
extends MeshInstance3D


@onready var timer := $Timer as Timer


func _ready() -> void:
	# duplicate the material, otherwise it will be shared among all instances
	var duplicated_material := material_override.duplicate()
	material_override = duplicated_material
	
	create_tween().tween_property(self, ^"material_override:albedo_color:a", 0.0, 0.05)


## To be called before adding this node to the scene tree
func create_trace(from: Vector3, to: Vector3) -> void:
	mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()


func _on_timer_timeout() -> void:
	queue_free()
