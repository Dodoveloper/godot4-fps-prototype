@tool
extends MeshInstance3D
## Tool script to adjust all ShaderMaterial's FOV.
## This is needed for the models' shader, which is used to fix gun clipping.
## Make sure to set it equal to the camera's FOV.


@export var viewmodel_fov: float = 75.0:
	set = set_viewmodel_fov


func set_viewmodel_fov(value: float) -> void:
	viewmodel_fov = value
	RenderingServer.global_shader_parameter_set(&"viewmodel_fov", value)
