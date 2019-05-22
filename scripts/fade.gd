extends Node2D

signal fade_over

var speed = 1.8
var val = 0
onready var fadein = false
onready var done = true

func _ready():
#	if fadein:
#		start_fadein()
#	else:
#		start_fadeout()
	pass

func display_without_fading():
	fadein = false
	done = true
	val = 0.0
	$black.modulate = Color(0, 0, 0, val)
	emit_signal("fade_over", val)

func start_fadein():
	print("Starting fade in")
	val = 1.0
	$black.modulate = Color(0, 0, 0, 1.0)
	fadein = false
	done = false
	
func start_fadeout():
	val = 0.0
	$black.modulate = Color(0, 0, 0, 0.0)
	fadein = true
	done = false

func _process(delta):
	if not done:
		if fadein:
			val += speed * delta
			if val > 1.0:
				val = 1.0
				done = true
				emit_signal("fade_over", val)
		else:
			val -= speed * delta
			if val < 0.0:
				val = 0.0
				done = true
				emit_signal("fade_over", val)
		$black.modulate = Color(0, 0, 0, val)
