class_name BulletTracer
extends MeshInstance3D


@export_range(0.1, 0.5, 0.1) var max_length := 0.3

@onready var timer := $Timer as Timer


func _ready() -> void:
	# duplicate the material, otherwise it will be shared among all instances
	var duplicated_material := material_override.duplicate()
	material_override = duplicated_material
	
	create_tween().tween_property(self, ^"material_override:albedo_color:a", 0.0, 0.05)


## To be called before adding this node to the scene tree
func create_trace(from: Vector3, to: Vector3) -> void:
	var direction := from.direction_to(to)
	var tracer_length := (to - from).length()
	
	if tracer_length > max_length:
		tracer_length = max_length
	var end_point := from + direction*tracer_length
	
	var start_point := from + direction * 0.2
	
	mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	mesh.surface_add_vertex(start_point)
	mesh.surface_add_vertex(end_point)
	mesh.surface_end()


func _on_timer_timeout() -> void:
	queue_free()
