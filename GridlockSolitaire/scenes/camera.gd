extends Camera2D

var ImportantContentRect = Rect2(0,-50,600,865)
var Center = Vector2(300,382.5)



func _ready():
	set_process(true)

func _process(delta):
	var ScreenSize = OS.get_window_size()
	var ratio = ScreenSize.x/ScreenSize.y
	var contentratio = ImportantContentRect.size.x/ImportantContentRect.size.y
	#self.set_scale(Vector2(ratio/contentratio,1))
	var zoomratio = ImportantContentRect.size.y/ScreenSize.y
	self.set_zoom(Vector2(zoomratio,zoomratio))
	
