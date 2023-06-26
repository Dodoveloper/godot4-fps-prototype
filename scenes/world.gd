extends Node3D


const BULLET_DECAL := preload("res://scenes/bullet_decal/bullet_decal.tscn")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_player_has_shot(raycast: RayCast3D) -> void:
	var b := BULLET_DECAL.instantiate()
	var collider := raycast.get_collider() as Node
	collider.add_child(b)
	b.global_transform.origin = raycast.get_collision_point()
	b.look_at(b.global_transform.origin + raycast.get_collision_normal())
