extends Node

var current_scene = null
var root = null
var music
var sfx
onready var loaded_settings_from_disk = false


func _ready():
	root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

	if not loaded_settings_from_disk:
		loaded_settings_from_disk = true
		var f = File.new()
		if !f.file_exists("user://settings.txt"):
			#nothing to load, let's set some defaults
			#print("leaving default settings")
			sfx = true
			music = true
		else:
			f.open("user://settings.txt", File.READ)
			var line = parse_json(f.get_line())
			
			if line.has("music"):
				music = line["music"]
			else:
				music = true

			if line.has("sfx"):
				sfx = line["sfx"]
			else:
				sfx = true

			f.close()

	#add sfx node
#	if !root.has_node("sfx"):
#		root.call_deferred("add_child", load("res://scenes/sfx.tscn").instance())

func save_settings():
	var save_data = {
		"music": music,
		"sfx": sfx,
#		"autoplay": auto,
#		"autodraw": autodraw,
#		"demodraw": demodraw
	}
	var save_file = File.new()
	save_file.open("user://settings.txt", File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.close()

	
	