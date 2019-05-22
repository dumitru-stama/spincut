extends Node2D

signal quit_to_menu

func _ready():
	pass # Replace with function body.

func _on_Timer_timeout():
	emit_signal("quit_to_menu")
