extends Node3D


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
