extends State


@export var bob_frequency_multiplier := 2
@export var bob_amplitude_multiplier := 4


func enter() -> void:
	(owner as Weapon).bob_frequency *= bob_frequency_multiplier
	(owner as Weapon).bob_amplitude *= bob_amplitude_multiplier


func exit() -> void:
	(owner as Weapon).bob_frequency /= bob_frequency_multiplier
	(owner as Weapon).bob_amplitude /= bob_amplitude_multiplier


func handle_input(event: InputEvent) -> InputEvent:
	if event.is_action_released("sprint"):
		finished.emit("idle")
	
	return super(event)
