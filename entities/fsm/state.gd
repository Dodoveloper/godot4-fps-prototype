class_name State
extends Node


signal finished(next_state_name: String)


# Initialize the state. E.g. change the animation
func enter() -> void:
	return


# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> InputEvent:
	return event


func update(_delta: float) -> void:
	return


func _on_animation_finished() -> void:
	return
