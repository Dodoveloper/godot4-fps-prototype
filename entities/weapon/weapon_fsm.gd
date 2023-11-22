class_name WeaponStateMachine
extends StateMachine


func _ready() -> void:
	# FSM initializations
	for state_node in get_children():
		(state_node as State).finished.connect(_change_state)
		states_map[String(state_node.name).to_lower()] = state_node
	initialize(start_state_path)


# Special case: we want the player (parent) to control the sprint state.
# This method is used to "synchronize" sprinting between player and weapon
func force_toggle_sprint(enabled: bool) -> void:
	_change_state("sprint" if enabled else "idle")
