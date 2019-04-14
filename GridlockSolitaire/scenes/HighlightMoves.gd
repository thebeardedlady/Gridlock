extends TextureButton

onready var Level = get_node("../../")

func _ready():
	pass # Replace with function body.


func _process(delta):
	if(pressed):
		Level.ShowMoves = true
	else:
		Level.ShowMoves = false
