extends Node3D
## Weapon model script.
## Takes care of implementing procedural visual recoil when shooting.


@export var recoil_rotation_x: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3.ONE
## The higher, the ligher the weapon will look when recoiling
@export var lerp_speed := 5.0

var target_rot := Vector3.ZERO
var target_pos := Vector3.ZERO
var current_time: float


func _ready() -> void:
	target_rot.y = rotation.y
	current_time = 1.0


func _physics_process(delta: float) -> void:
	if current_time < 1.0:
		current_time += delta
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)
		
		target_rot.z = recoil_rotation_z.sample(current_time) * -recoil_amplitude.y
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z


## Called in the weapon's shoot state
func apply_recoil() -> void:
	target_rot.z = recoil_rotation_z.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0.0
