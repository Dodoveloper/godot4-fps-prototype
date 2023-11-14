extends Node3D


const FADE_OUT_DURATION := 0.5

@onready var mesh := $MeshInstance3D as MeshInstance3D


func _on_life_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(mesh, "transparency", 0.0, FADE_OUT_DURATION)
	tween.tween_callback(queue_free)
