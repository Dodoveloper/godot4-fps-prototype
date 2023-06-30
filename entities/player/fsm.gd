class_name PlayerStateMachine
extends StateMachine


var can_sprint := true

@onready var sprint_cooldown := Timer.new()


func _ready() -> void:
	# FSM initializations
	for state_node in get_children():
		(state_node as State).finished.connect(_change_state)
		states_map[String(state_node.name).to_lower()] = state_node
	initialize(start_state_path)
	# sprint cooldown
	add_child(sprint_cooldown)
	sprint_cooldown.one_shot = true
	sprint_cooldown.timeout.connect(_on_sprint_cooldown_timeout)


func _on_sprint_cooldown_timeout() -> void:
	can_sprint = true
	print("sprint cooldown timeout")


func _on_sprint_exited(wait_time: float, time_left: float) -> void:
	can_sprint = false
	sprint_cooldown.start(wait_time - time_left)
	print("sprint cooldown: ", sprint_cooldown.wait_time)
