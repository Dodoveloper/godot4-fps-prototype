class_name StateMachine
extends Node


signal state_changed(states_stack: Array)

@export var start_state_path: NodePath
@export var states_stack_count := 2

var states_stack := []
var current_state: State = null
var states_map := {}
var is_input_blocked := false


func _physics_process(delta: float) -> void:
	current_state.update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if is_input_blocked:
		return
	current_state.handle_input(event)


func initialize(state_path: NodePath) -> void:
	states_stack.push_front(get_node(state_path))
	current_state = states_stack[0]
	current_state.enter()


func _change_state(state_name: String) -> void:
	# exit the current state
	current_state.exit()
	states_stack.push_front(states_map[state_name])
	if states_stack.size() > states_stack_count:
		states_stack.pop_back()
	# enter the new one
	current_state = states_stack[0]
	state_changed.emit(states_stack)
	current_state.enter()


func _on_animation_finished() -> void:
	current_state._on_animation_finished()
