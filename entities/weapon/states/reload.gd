extends State


@onready var reload_timer := $ReloadTimer as Timer


func enter() -> void:
	(owner as Weapon).can_sprint = false
	reload_timer.start((owner as Weapon).reload_time)
	(owner as Weapon).anim_player.play("reloading")


func exit() -> void:
	(owner as Weapon).can_sprint = true


func _on_animation_finished() -> void:
	return


func _on_reload_timer_timeout() -> void:
	(owner as Weapon).cur_ammo = (owner as Weapon).mag_size
	finished.emit("idle" if not Input.is_action_pressed("fire1") else "shoot")
