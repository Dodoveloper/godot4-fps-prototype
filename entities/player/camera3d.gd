extends Camera3D


@export var trauma_reduction_rate := 2.0
@export var max_y := 10.0
@export var max_z := 5.0
@export var noise: FastNoiseLite
@export var noise_speed := 50.0

var trauma := 0.0
var time := 0.0

@onready var initial_rotation := rotation_degrees


func _process(delta: float) -> void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	rotation_degrees.y = initial_rotation.y + max_y \
			* _get_shake_intensity() * _get_noise_from_seed(1)
	rotation_degrees.z = initial_rotation.z + max_z \
			* _get_shake_intensity() * _get_noise_from_seed(2)


func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)


func _get_shake_intensity() -> float:
	return trauma * trauma


func _get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
