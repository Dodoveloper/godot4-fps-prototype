extends Weapon


@export var fire_range := 10


func _ready() -> void:
	# tweak the raycast size
	raycast.target_position.z = -fire_range
