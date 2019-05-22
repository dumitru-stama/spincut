extends Node2D

signal quit_to_menu
signal previous_scene
signal named_scene

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	emit_signal("quit_to_menu")

func _on_Button2_pressed():
	emit_signal("previous_scene")

func _on_Button3_pressed():
	emit_signal("named_scene", "splash")
