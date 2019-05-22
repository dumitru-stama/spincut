extends Node2D

signal previous_scene
signal next_scene

func _ready():
	pass

func _on_Button_pressed():
	emit_signal("next_scene")

func _on_Button2_pressed():
	emit_signal("previous_scene")
