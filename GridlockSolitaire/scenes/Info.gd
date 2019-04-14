extends TextureButton

var InstructionsVisible = false
#onready var Level = get_node("../../")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Info_pressed():
	if(not InstructionsVisible):
		InstructionsVisible = true
		#Level.set_process(false)
		get_node("instructions").popup_centered()
	else:
		InstructionsVisible = false
		get_node("instructions").hide()
		#Level.set_process(true)
