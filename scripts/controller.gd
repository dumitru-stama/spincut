extends Node2D

enum STATE {
	splash_screen,
	quit_to_menu,
	quit_overlay,
	quit_overlay_load_named_scene,
	previous_scene,
	next_scene,
	named_scene,
	named_overlay,
	quit
	}

var current_scene

# this variable will hold the name of the scene to switch to if signal
# named_scene was emmited
var switch_to_named_scene

# this var is set when we want to go back to home menu
var current_state

# will be true only when quitting

onready var overlay = {
	0: {
		"name": "settings",
		"scn": "res://scenes/test_overlay.tscn",
		"signals": ["quit_overlay", "quit_overlay_load_named_scene"],
		"full_transparency": false
		},
	}

onready var scene = {
	0: {
		"name": "splash",
		"scn": "res://scenes/splash.tscn",
		"signals": ["quit_to_menu"],
		},
	1: {
		"name": "menu",
		"scn": "res://scenes/test_scene_1.tscn",
		"signals": ["next_scene", "quit", "named_overlay"]
		},
	2: {
		"name": "scene_2",
		"scn": "res://scenes/test_scene_2.tscn",
		"signals": ["previous_scene", "next_scene"]
		},
	3: {
		"name": "scene_3",
		"scn": "res://scenes/test_scene_3.tscn",
		"signals": ["previous_scene", "quit_to_menu", "named_scene"],
		"no_fade_in": true
		}
	}

onready var sc = $scene
onready var ov = $overlay
onready var music = globals.root.get_node("controller").get_node("music")
#onready var sfx = globals.root.get_node("controller").get_node("sfx")

#--------------------------------------------------------------
func _ready():
	current_state = STATE.splash_screen
	add_named_scene("splash")

func remove_scene():
	if sc.get_child_count() > 0:
		var child = sc.get_child(0)
		sc.remove_child(child)
		if child != null:
			child.call_deferred("free")

func reconnect_signals(s, i):
	for sig in scene[i]["signals"]:
		if sig is Array:
			if !s.get_node(sig[0]).is_connected(sig[1], self, "_on_" + String(sig[1])):
				s.get_node(sig[0]).connect(sig[1], self, "_on_" + String(sig[1]))
		else:
			if !s.is_connected(sig, self, "_on_" + String(sig)):
				s.connect(sig, self, "_on_" + String(sig))

func add_scene(i):
	current_scene = i
	print("Loading scene " + scene[i]["name"])
	var s = load(scene[i]["scn"]).instance()
	# connect all available signals
	reconnect_signals(s, i)
#	for sig in scene[i]["signals"]:
#		if sig is Array:
#			s.get_node(sig[0]).connect(sig[1], self, "_on_" + String(sig[1]))
#		else:
#			s.connect(sig, self, "_on_" + String(sig))
	sc.add_child(s)
	start_music(i)
	if scene[i].has("no_fade_in") and scene[i]["no_fade_in"] == true:
		print("no fade in is true")
		$fade.display_without_fading()
	else: 
		$fade.start_fadein()

func find_scene_name(n):
	for e in scene.keys():
		if scene[e]["name"] == n:
			return [true, e]
	return [false, ""]

func add_named_scene(n):
	var scn = find_scene_name(n)
	if scn[0]:
		add_scene(scn[1])
		return true
	else:
		return false

func start_music(i):
	if scene[i].has("music"):
		music.start_music(scene[i]["music"])
	else:
		music.stop_music()

func _on_fade_over(val):
	#print("FADE OVER: val: " + String(val))
	if val >= 1:
		remove_scene()
		$overlay_mask.hide()

		if current_state == STATE.previous_scene:
			#print("it is next scene")
			if scene.has(current_scene - 1):
				current_scene -= 1
				#print("next exists: " + String(current_scene))
				add_scene(current_scene)
			else:
				if !add_named_scene("menu"):
					quit()

		elif current_state == STATE.next_scene:
			#print("it is next scene")
			if scene.has(current_scene + 1):
				current_scene += 1
				#print("next exists: " + String(current_scene))
				add_scene(current_scene)
			else:
				if !add_named_scene("menu"):
					quit()
		
		elif current_state == STATE.named_scene:
			if !add_named_scene(switch_to_named_scene):
				quit()

		elif current_state == STATE.quit:
			quit()
		
		else:
			if !add_named_scene("menu"):
				quit()

		#$fade.start_fadein()

	else:
		#print("End Fade In to scene")
		pass

# recursive function to find all buttons from a scene and disable/enable them
func modify_all_buttons(start_node, enable):
	for node in start_node.get_children():
		if node.get_child_count() > 0:
			modify_all_buttons(node, enable)
		else:
			if node is Button:
				if !enable and !node.disabled:
					node.disabled = true
					node.hint_tooltip = "enabled"
				if enable and node.disabled and node.hint_tooltip == "enabled":
					node.disabled = false

func _on_previous_scene():
	current_state = STATE.previous_scene
	if scene.has(current_scene - 1):
		if scene[current_scene-1].has("no_fade_in") and scene[current_scene-1]["no_fade_in"] == true:
			current_scene -= 1
			remove_scene()
			$overlay_mask.hide()
			add_scene(current_scene)
		else:
			$fade.start_fadeout()

func _on_next_scene():
	current_state = STATE.next_scene
	if scene.has(current_scene + 1):
		if scene[current_scene+1].has("no_fade_in") and scene[current_scene+1]["no_fade_in"] == true:
			current_scene += 1
			remove_scene()
			$overlay_mask.hide()
			add_scene(current_scene)
		else:
			$fade.start_fadeout()

func _on_named_scene(s):
	var scene_id
	switch_to_named_scene = s
	current_state = STATE.named_scene
	scene_id = find_scene_name(s)
	if scene_id[0]:
		if scene[scene_id[1]].has("no_fade_in") and scene[scene_id[1]]["no_fade_in"] == true:
			current_scene = scene_id[1]
			remove_scene()
			$overlay_mask.hide()
			add_scene(current_scene)
		else:
			$fade.start_fadeout()

func _on_named_overlay(o):
	for i in overlay.keys():
		if overlay[i]["name"] == o:
			if !overlay[i].has("full_transparency") or (overlay[i].has("full_transparency") and overlay[i]["full_transparency"] == false):
				$overlay_mask.show()
			var s = load(overlay[i]["scn"]).instance()
			# connect all available signals
			for sig in overlay[i]["signals"]:
				s.connect(sig, self, "_on_" + String(sig))
			ov.add_child(s)
	modify_all_buttons($scene, false)
	$scene.get_child(0).set_process_input(false)

func remove_overlay():
	if ov.get_child_count() > 0:
		var child = ov.get_child(0)
		ov.remove_child(child)
		if child != null:
			child.call_deferred("free")

func _on_quit_overlay():
	remove_overlay()
	$overlay_mask.hide()
	modify_all_buttons($scene, true)
	$scene.get_child(0).set_process_input(true)

func _on_quit_overlay_load_named_scene(s):
	remove_overlay()
	_on_named_scene(s)

func _on_quit_to_menu():
	current_state = STATE.quit_to_menu
	$fade.start_fadeout()

func _on_quit():
	current_state = STATE.quit
	music.stop_music()
	#music.connect("music_stopped", self, "_on_music_stopped")
	$fade.start_fadeout()

func _on_music_stopped():
	#print("Music really stopped")
	pass

func quit():
	get_tree().quit()




