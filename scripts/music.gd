extends Node2D

enum FADE {
	fadein,
	fadeout
}

signal music_lowered_for_speech
signal music_stopped

const FADE_SPEED = 80
const VOLUME_ON = -20
const VOLUME_OFF = -80
const VOLUME_DURING_SPEECH = -35

#var muzica = {
#	"normal": [	"res://assets/audio/bcc-031814-ballet-piano-847.ogg",
#				"res://assets/audio/kids-and-puppies-full-1_GkxOQIEd.ogg",
#				],
#	"fight": ["res://assets/audio/ssm-102518-butterfly-fun-piano-only.ogg"]
#}
var muzica = {
	"normal": [],
	"fight": []
}
onready var music_collection = "normal"
var music_index = 0

var switch_to_collection = ""
var fadeout = 0
var fadein = 0
var fade_direction = FADE.fadeout		#0 = fadeout, 1 = fadein

var stopping_music = false
var lower_for_speech = false
var current_max_volume = VOLUME_ON

func _ready():
	$AudioStreamPlayer.volume_db = VOLUME_OFF

func resume_collection():
	if globals.music && !$AudioStreamPlayer.playing:
		#music is not playing so let's fade in
		fade_direction = FADE.fadein
		fadein = $AudioStreamPlayer.volume_db
		load_music_track()
		switch_to_collection = music_collection

func start_music(collection):
	current_max_volume = VOLUME_ON
	if globals.music:
		if collection == music_collection:
			if !$AudioStreamPlayer.playing:
				#music is not playing so let's fade in
				resume_collection()
		else:
			fadein = VOLUME_OFF
			if $AudioStreamPlayer.playing:
				fadeout = $AudioStreamPlayer.volume_db
				fade_direction = FADE.fadeout
			else:
				fadeout = VOLUME_OFF
				fade_direction = FADE.fadein
				music_collection = collection
				load_music_track()
			music_index = 0
			switch_to_collection = collection

func stop_music():
	#print("STOP MUSIC")
	if $AudioStreamPlayer.playing:
		fadeout = $AudioStreamPlayer.volume_db
		switch_to_collection = ""
		stopping_music = true
	else:
		$AudioStreamPlayer.volume_db = VOLUME_OFF

func fade_out_for_speech():
	current_max_volume = VOLUME_DURING_SPEECH
	if $AudioStreamPlayer.volume_db > VOLUME_DURING_SPEECH:
		fadeout = $AudioStreamPlayer.volume_db
		fade_direction = FADE.fadeout
		lower_for_speech = true
	else:
		lower_for_speech = false
		emit_signal("music_lowered_for_speech")

func fade_volume_max():
	if switch_to_collection == "" and !stopping_music:
		current_max_volume = VOLUME_ON
		if $AudioStreamPlayer.playing and $AudioStreamPlayer.volume_db < VOLUME_ON:
			fadein = $AudioStreamPlayer.volume_db
			fade_direction = FADE.fadein
			lower_for_speech = true
		else:
			lower_for_speech = false
			$AudioStreamPlayer.volume_db = VOLUME_OFF

func _on_AudioStreamPlayer_finished():
	music_index += 1
	if muzica[music_collection].size() <= music_index:
		music_index = 0
	fade_direction = FADE.fadein
	fadein = VOLUME_OFF
	$AudioStreamPlayer.volume_db = fadein
	load_music_track()
	switch_to_collection = music_collection
	
func load_music_track():
	var newtrack = load(muzica[music_collection][music_index])
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = newtrack
	$AudioStreamPlayer.play()

func _process(delta):
	if stopping_music:
		if fadeout > VOLUME_OFF:
			fadeout -= delta * FADE_SPEED
			$AudioStreamPlayer.volume_db = fadeout
		else:
			stopping_music = false
			$AudioStreamPlayer.volume_db = VOLUME_OFF
			$AudioStreamPlayer.stop()
			emit_signal("music_stopped")

	elif switch_to_collection != "":
		if fade_direction == FADE.fadeout:
			if fadeout > VOLUME_OFF:
				fadeout -= delta * FADE_SPEED
				$AudioStreamPlayer.volume_db = fadeout
			else:
				fade_direction = FADE.fadein
				music_collection = switch_to_collection
				fadeout = VOLUME_OFF
				$AudioStreamPlayer.volume_db = fadeout
				load_music_track()
		else:
			if fadein < current_max_volume:
				fadein += delta * FADE_SPEED
				$AudioStreamPlayer.volume_db = fadein
			else:
				switch_to_collection = ""
				fade_direction = FADE.fadeout
				fadein = current_max_volume
				$AudioStreamPlayer.volume_db = fadein

	elif lower_for_speech:
		if fade_direction == FADE.fadeout:
			if fadeout > VOLUME_DURING_SPEECH:
				fadeout -= delta * (FADE_SPEED / 2.0)
				$AudioStreamPlayer.volume_db = fadeout
			else:
				$AudioStreamPlayer.volume_db = VOLUME_DURING_SPEECH
				lower_for_speech = false
				emit_signal("music_lowered_for_speech")
		else:
			if fadein < current_max_volume:
				fadein += delta * (FADE_SPEED / 2.0)
				$AudioStreamPlayer.volume_db = fadein
			else:
				$AudioStreamPlayer.volume_db = current_max_volume
				lower_for_speech = false
