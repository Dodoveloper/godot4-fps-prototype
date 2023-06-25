extends Camera3D


@export var camera_path: NodePath

@onready var camera := get_node(camera_path) as Camera3D


func _process(_delta: float) -> void:
	# make the gun camera follow the main camera
	global_transform = camera.global_transform
