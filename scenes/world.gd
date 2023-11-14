extends Node3D


const BULLET_DECAL := preload("res://scenes/bullet_decal/bullet_decal.tscn")

@onready var decals_container := $Decals as Node3D
@onready var enemies_room1 := $FirstFloor/EnemiesRoom1 as Node3D
@onready var enemies_room1_count := enemies_room1.get_child_count()
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	for enemy in enemies_room1.get_children():
		(enemy as Enemy).destroyed.connect(_on_Enemy_destroyed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_Enemy_destroyed() -> void:
	enemies_room1_count -= 1
	if enemies_room1_count == 0:
		anim_player.play("open_door1")


func _on_player_decal_requested(collision_info: Dictionary) -> void:
	var decal := BULLET_DECAL.instantiate()
	decals_container.add_child(decal)
	decal.global_position = collision_info["position"]
	var collision_normal := collision_info["normal"] as Vector3
	decal.look_at(decal.global_position + collision_normal,
			Vector3.RIGHT if collision_normal in [Vector3.UP, Vector3.DOWN] else Vector3.UP)
