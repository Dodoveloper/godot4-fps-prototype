extends Node3D


const FADE_OUT_DURATION := 0.5


func _on_life_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property($MeshInstance3D, "transparency", 1.0, FADE_OUT_DURATION)
	tween.tween_callback(queue_free)
