extends Sprite

onready var Level = get_node("../")

func _ready():
	set_process(true)


func _draw():
	
	draw_texture_rect(get_texture(),Rect2(281.25,436.917786,768*1.633464,512*1.905929),true)
	
	for y in range(Level.Dim.y):
		for x in range(Level.Dim.x):
			var pos = Vector2((x+0.5)*Level.Increment.x-0.5*Level.CardScale.x*Level.CardTextureSize.x,(y+0.5)*Level.Increment.y-0.5*Level.CardScale.y*Level.CardTextureSize.y)
			var Rect = Rect2(pos,Vector2(Level.CardScale.x*Level.CardTextureSize.x,Level.CardScale.y*Level.CardTextureSize.y))
			draw_rect(Rect,Color(0.1,0.1,0.1,0.4))


func _process(delta):
	update()
