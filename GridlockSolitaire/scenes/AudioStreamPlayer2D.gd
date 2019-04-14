extends AudioStreamPlayer2D


var CardSounds = []
var UISounds = []

func _ready():
	CardSounds.append(load("res://sounds/cardPlace1.ogg"))
	CardSounds.append(load("res://sounds/cardPlace2.ogg"))
	CardSounds.append(load("res://sounds/cardPlace3.ogg"))
	CardSounds.append(load("res://sounds/cardSlide1.ogg"))
	CardSounds.append(load("res://sounds/cardSlide2.ogg"))
	CardSounds.append(load("res://sounds/cardSlide3.ogg"))
	
	UISounds.append(load("res://sounds/click1.wav"))
	UISounds.append(load("res://sounds/click2.wav"))
	UISounds.append(load("res://sounds/click3.wav"))
	UISounds.append(load("res://sounds/click4.wav"))
	UISounds.append(load("res://sounds/click5.wav"))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
