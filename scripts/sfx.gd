extends Node2D

onready var streams = {}
onready var soundplay = $soundplay

func _ready():
	pass

func play(s):
	var snd = "res://assets/audio/" + s +".ogg"
	if globals.sfx:
		if !streams.has(snd):
			streams[snd] = load(snd)
		soundplay.stream = streams[snd]
		soundplay.play()
