extends Control

signal quit_overlay
signal quit_overlay_load_named_scene

onready var music = globals.root.get_node("controller").get_node("music")
onready var sfx = globals.root.get_node("controller").get_node("sfx")

func _ready():
	music.fade_out_for_speech()

func _unhandled_input(e):
	if e is InputEventMouseButton:
		sfx.play("pop")
		get_tree().set_input_as_handled()
		_on_Button_pressed()

func _on_Button_pressed():
	music.fade_volume_max()
	emit_signal("quit_overlay")

func _on_goto_scene3_pressed():
	emit_signal("quit_overlay_load_named_scene", "scene_3")
