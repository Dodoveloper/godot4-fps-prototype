extends World


@onready var enemies_room1 := $FirstFloor/EnemiesRoom1 as Node3D
@onready var enemies_room1_count := enemies_room1.get_child_count()
@onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	for enemy in enemies_room1.get_children():
		(enemy as Enemy).destroyed.connect(_on_Enemy_destroyed)


func _on_Enemy_destroyed() -> void:
	enemies_room1_count -= 1
	if enemies_room1_count == 0:
		anim_player.play("open_door1")
