extends Node2D

signal next_scene
signal named_overlay
signal quit

func _ready():
	pass

func _on_Button_pressed():
	emit_signal("next_scene")

func _on_quit_pressed():
	emit_signal("quit")

func _on_settings_pressed():
	emit_signal("named_overlay", "settings")
