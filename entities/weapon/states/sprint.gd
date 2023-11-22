extends State
## Weapon's sprint state.
## This state is an exception, because it's not triggered by other weapon states,
## but it's forced by the state machine, which in turn gets notified by the
## player script about when to toggle this state.


@export var bob_frequency_multiplier := 2
@export var bob_amplitude_multiplier := 4


func enter() -> void:
	(owner as Weapon).bob_frequency *= bob_frequency_multiplier
	(owner as Weapon).bob_amplitude *= bob_amplitude_multiplier


func exit() -> void:
	(owner as Weapon).bob_frequency /= bob_frequency_multiplier
	(owner as Weapon).bob_amplitude /= bob_amplitude_multiplier
