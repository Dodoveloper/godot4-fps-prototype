extends Node3D


const BULLET_DECAL := preload("res://scenes/bullet_decal/bullet_decal.tscn")

@onready var decals_container := $Decals as Node3D
@onready var enemies_room1 := $FirstFloor/EnemiesRoom1 as Node3D
@onready var enemies_room1_count := enemies_room1.get_child_count()


func _ready() -> void:
	for enemy in enemies_room1.get_children():
		(enemy as Enemy).destroyed.connect(_on_Enemy_destroyed)
#	await get_tree().create_timer(10.0).timeout
#	$AnimationPlayer.play("open_door2")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_Enemy_destroyed() -> void:
	enemies_room1_count -= 1
	if enemies_room1_count == 0:
		$AnimationPlayer.play("open_door1")


func _on_player_has_shot(raycast: RayCast3D) -> void:
	var decal := BULLET_DECAL.instantiate()
	raycast.get_collider().add_child(decal)
	decal.global_position = raycast.get_collision_point()
	decal.look_at($Player/Head.global_rotation, raycast.get_collision_normal())
	# TODO: keep the number of decals down
