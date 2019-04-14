extends Sprite


var Sprites = []
var Rate = 0.48
var Count = 0.0
var CurrentIndex = 0


func _ready():
	Sprites.append(load("res://gui/Victory.png"))
	Sprites.append(load("res://gui/Victory - 2.png"))
	Sprites.append(load("res://gui/Victory - 3.png"))
	Sprites.append(load("res://gui/Victory - 4.png"))
	Sprites.append(load("res://gui/Victory - 5.png"))
	Sprites.append(load("res://gui/Victory - 6.png"))

func _process(delta):
	Count += delta
	if(Count >= Rate):
		Count -= Rate
		CurrentIndex = (CurrentIndex+1)%Sprites.size()
		set_texture(Sprites[CurrentIndex])
