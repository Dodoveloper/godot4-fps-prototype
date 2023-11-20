class_name World
extends Node3D


const BULLET_DECAL := preload("res://scenes/bullet_decal/bullet_decal.tscn")
const BULLET_TRACER := preload("res://scenes/bullet_tracer/bullet_tracer.tscn")

@onready var tracers_container := $Tracers as Node3D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_player_decal_requested(collision_info: Dictionary) -> void:
	var decal := BULLET_DECAL.instantiate()
	(collision_info["collider"] as Node).add_child(decal)
	decal.global_position = collision_info["position"]
	var collision_normal := collision_info["normal"] as Vector3
	decal.look_at(decal.global_position + collision_normal,
			Vector3.RIGHT if collision_normal in [Vector3.UP, Vector3.DOWN] else Vector3.UP)


func _on_player_tracer_requested(from: Vector3, to: Vector3) -> void:
	var tracer := BULLET_TRACER.instantiate() as BulletTracer
	tracer.create_trace(from, to)
	tracers_container.add_child(tracer)
