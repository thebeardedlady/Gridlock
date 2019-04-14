extends TextureButton

onready var Level = get_node("../../")

func _ready():
	set_process(true)

func _process(delta):
	set_disabled((Level.Undo.size() == 0))


func _on_Undo_pressed():
	Level.UndoMove(Level.Tableau,Level.Waste,Level.Undo)
