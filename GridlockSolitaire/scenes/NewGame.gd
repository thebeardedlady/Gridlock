extends TextureButton


onready var Level = get_node("../../")

func _ready():
	set_process(false)

func _process(delta):
	if(get_node("confirm").is_visible()):
		Level.set_process(false)
	else:
		Level.set_process(true)
		set_process(false)


func _on_NewGame_pressed():
	set_process(true)
	get_node("confirm").popup_centered()
	Level.set_process(false)


func _on_confirm_confirmed():
	
	for y in range(Level.Dim.y):
		for x in range(Level.Dim.x):
			for i in range(Level.Tableau[y*Level.Dim.x+x].size()):
				Level.Waste.append(Level.Tableau[y*Level.Dim.x+x][i])
			Level.Tableau[y*Level.Dim.x+x].clear()
	Level.set_process(true)
	Level.NewGame(Level.Tableau,Level.Waste,48)
