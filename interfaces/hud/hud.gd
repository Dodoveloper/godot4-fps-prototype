class_name Hud
extends Control


@onready var crosshair := $Crosshair as TextureRect
@onready var fps_label := $FpsLabel as Label
@onready var player_state_label := $PlayerStateLabel as Label
@onready var weapon_state_label := $WeaponStateLabel as Label
@onready var heat_label := $HeatLabel as Label
@onready var ammo_label := $AmmoLabel as Label


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %s" % [Engine.get_frames_per_second()]


func _on_weapon_heat_changed(value: int) -> void:
	heat_label.text = str(value)
