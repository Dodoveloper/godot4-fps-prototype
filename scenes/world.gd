extends Node3D


const BULLET_DECAL := preload("res://scenes/bullet_decal/bullet_decal.tscn")

@onready var decals_container := $Decals as Node


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_player_has_shot(raycast: RayCast3D) -> void:
	var b := BULLET_DECAL.instantiate()
	raycast.get_collider().add_child(b)
	b.global_transform.origin = raycast.get_collision_point()
	var collision_normal := raycast.get_collision_normal()
	if collision_normal in [Vector3.UP, Vector3.DOWN]:
		b.look_at(b.global_transform.origin + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		b.look_at(b.global_transform.origin + raycast.get_collision_normal(), Vector3.UP)
	# TODO: keep the number of decals down
