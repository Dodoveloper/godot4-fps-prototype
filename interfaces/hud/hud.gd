class_name Hud
extends Control


@onready var crosshair := $Crosshair as TextureRect
@onready var fps_label := $FpsLabel as Label


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %s" % [Engine.get_frames_per_second()]


func _on_weapon_ads_toggled(enabled: bool) -> void:
	crosshair.visible = not enabled
