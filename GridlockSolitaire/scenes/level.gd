#TODO(ian): Things to do before posting on discord/itch
#1. undo (X)
#2. restart?
#3. new game (X)
#4. help/instructions (X)
#5. menu buttons (X)
#6. animations? (x)
#7. win and loss acknowledgement ()
#8. flexible rendering? (X)
#9. sound? (NO)
#10. save game (X)


extends Node2D


onready var RegularTweens = get_node("Tween")
var Dim = Vector2(7,7)
var Empty = Vector2(3,3)
var TotalCards = 48
var Tableau = []
var Waste = []
var Increment = Vector2(86,116) 
var MovingCard = []
var PreviousLMB = false
var PreviousRMB = false
var CardScale = Vector2(0.55,0.55)
var CardTextureSize = Vector2(140,190)
var Undo = []
var SaveVersion = 0
var mousepos = Vector2(-1,-1)
var LMB = false
var ShowMoves = false
var ScreenIsTouched = false

func _ready():
	
	randomize()
	
	#Add save file here
	for i in range(Dim.y):
		for j in range(Dim.x):
			Tableau.append([])
	
	
	if(OS.has_touchscreen_ui_hint()):
		set_process_input(true)
	
	
	var StartNew = false
	#move_child(get_node("shadows"),0)
	if(not File.new().file_exists("user://gridlock.sav")):
		StartNew = true
	else:
		var string = load_file("user://gridlock.sav")
		if(string.length() == 0):
			StartNew = true
		else:
			var split = string.split(",",false)
			var index = 0
			
			SaveVersion = split[index].to_int()
			index += 1
			Empty.x = split[index].to_float()
			index += 1
			Empty.y = split[index].to_float()
			index += 1
			
			var CardBack = load("res://art/Back_B5.png")
			for i in range(split[index].to_int()):
				index += 1
				var card = load("res://scenes/card.tscn").instance()
				card.CardInfo = split[index]
				card.FaceUpTexture = load("res://art/" + card.CardInfo + ".png")
				card.FaceDownTexture = CardBack
				card.set_texture(card.FaceDownTexture)
				card.set_position(Vector2(Increment.x*(Empty.x+0.5),Increment.y*(Empty.y+0.5)))
				card.set_scale(CardScale)
				Waste.append(card)
				add_child(card)
			
			index += 1
			
			
			for y in range(Dim.y):
				for x in range(Dim.x):
					for i in range(split[index].to_int()):
						index += 1
						var card = load("res://scenes/card.tscn").instance()
						card.CardInfo = split[index]
						card.FaceUpTexture = load("res://art/" + card.CardInfo + ".png")
						card.FaceDownTexture = CardBack
						card.set_texture(card.FaceUpTexture)
						card.set_position(Vector2(Increment.x*(Empty.x+0.5),Increment.y*(Empty.y+0.5)))
						card.set_scale(CardScale)
						Tableau[y*Dim.x+x].append(card)
						add_child(card)
					index += 1
		
		
		
	if(StartNew):
		var CardBack = load("res://art/Back_B5.png")
		var NumCards = 0
		for suit in ["C","S","D","H"]:
			for rank in ["A","2","3","4","5","6","7","8","9","X","J","Q"]:
				Waste.append(load("res://scenes/card.tscn").instance())
				Waste[NumCards].CardInfo = suit+rank
				Waste[NumCards].FaceUpTexture = load("res://art/" + Waste[NumCards].CardInfo + ".png")
				Waste[NumCards].FaceDownTexture = CardBack
				Waste[NumCards].set_texture(Waste[NumCards].FaceUpTexture)
				Waste[NumCards].set_position(Vector2(Increment.x*(Empty.x+0.5),Increment.y*(Empty.y+0.5)))
				Waste[NumCards].set_scale(CardScale)
				NumCards += 1
		
		for card in Waste:
			add_child(card)
		
		NewGame(Tableau,Waste,NumCards)




func _input(event):
	if(event is InputEventScreenTouch):
		mousepos = event.position
		LMB = event.pressed
		ScreenIsTouched = true
	elif(event is InputEventScreenDrag):
		mousepos = event.position
		LMB = true
		ScreenIsTouched = true
	elif(event is InputEventMagnifyGesture):
		var camera = get_node("camera")
		var zoom = camera.get_zoom()
		zoom.x *= event.factor
		zoom.y *= event.factor
		camera.set_zoom(zoom)


func save_file(content,path):
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(content)
	file.close()

func load_file(path):
	var file = File.new()
	file.open(path, file.READ)
	var content = file.get_as_text()
	file.close()
	return content

func SaveGame():
	var content = str(SaveVersion) + ","
	content += str(Empty.x) + "," + str(Empty.y) + ","
	content += str(Waste.size()) + ","
	for card in Waste:
		content += card.CardInfo + ","
	
	for pile in Tableau:
		content += str(pile.size()) + ","
		for card in pile:
			content += card.CardInfo + ","
	
	save_file(content,"user://gridlock.sav")



func NewGame(Tableau,Deck,NumCards):
	Shuffle(Deck)
	RegularTweens.remove_all()
	NumCards -= 1
	Empty.x = randi()%convert(Dim.x,TYPE_INT)
	Empty.y = randi()%convert(Dim.y,TYPE_INT)
	if(get_node("Win").is_active()):
		get_node("Win").remove_all()
	get_node("victory").hide()
	for y in range(Dim.y):
		for x in range(Dim.x):
			if(y != Empty.y or x != Empty.x):
				Tableau[y*Dim.x+x].append(Deck[NumCards])
				Deck[NumCards].set_texture(Deck[NumCards].FaceUpTexture)
				Deck[NumCards].Animating = true
				var pos = Vector2((x+0.5)*Increment.x,(y+0.5)*Increment.y)
				RegularTweens.interpolate_property(Deck[NumCards],"position",Deck[NumCards].get_position(),pos,1.0,Tween.TRANS_SINE,Tween.EASE_IN)
				NumCards -= 1
	RegularTweens.start()
	Deck.clear()
	Undo.clear()
	SaveGame()


func Shuffle(Deck):
	for i in range(Deck.size()-1,0,-1):
		var index = randi() % (i+1)
		var Temp = Deck[i]
		Deck[i] = Deck[index]
		Deck[index] = Temp


func Match(CardA, CardB):
	var Result = false
	if(CardA.substr(0,1) == CardB.substr(0,1)):
		Result = true
	elif(CardA.substr(1,1) == CardB.substr(1,1)):
		Result = true
	return Result

func IsEmpty(Pos):
	var index = Pos.y*Dim.x+Pos.x
	return (Tableau[index].size() == 0)


func CanMoveInDirection(Card,Pos,Dir):
	var NewPos = Pos + Dir
	var BoardRect = Rect2(0,0,6.5,6.5)
	
	if(BoardRect.has_point(NewPos)):
		if(IsEmpty(NewPos)):
			return false
	
	var CanMove = false
	var NextPos = Pos + Dir
	
	while(BoardRect.has_point(NextPos)):
		var index = NextPos.y*Dim.x+NextPos.x
		if(Tableau[index].size() > 0):
			if(Match(Tableau[index][Tableau[index].size()-1].CardInfo,Card.CardInfo)):
				CanMove = true
				break
		NextPos += Dir
	
	if(NextPos.x == NewPos.x and NextPos.y == NewPos.y):
		CanMove = false
	
	return CanMove


func FindMatchingInDir(Card,Pos,Dir):
	var BoardRect = Rect2(0,0,6.5,6.5)
	while(BoardRect.has_point(Pos)):
		var index = Pos.y*Dim.x+Pos.x
		if(Tableau[index].size() > 0):
			var SecondCard = Tableau[index][Tableau[index].size()-1]
			if(Match(SecondCard.CardInfo,Card.CardInfo)):
				return SecondCard
		Pos += Dir
	
	return null


func TDistance(A,B):
	return abs(A.x-B.x)+abs(A.y-B.y)


func IsPositionViable(Card,Pos,NewPos,InfoArray):
	var Directions = [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]
	for i in range(Directions.size()-1):
		var Min = 10.0
		var index = i
		for j in range(i,Directions.size()):
			var Dist = TDistance(Pos+Directions[j],NewPos)
			if(Dist < Min):
				index = j
				Min = Dist
		var temp = Directions[i]
		Directions[i] = Directions[index]
		Directions[index] = temp
	
	for dir in Directions:
		var NextPos = Pos+dir
		var index = NextPos.y*Dim.x+NextPos.x
		if(NextPos.x == NewPos.x and NextPos.y == NewPos.y):
			if(CanMoveInDirection(Card,Pos,dir) or Match(Card.CardInfo,Tableau[index][Tableau[index].size()-1].CardInfo)):
				InfoArray.append(NewPos)
				return true
	
	
	for dir in Directions:
		if(CanMoveInDirection(Card,Pos,dir)):
			var NextPos = Pos+dir
			if(not InfoArray.has(NextPos)):
				InfoArray.append(NextPos)
				if(IsPositionViable(Card,NextPos,NewPos,InfoArray)):
					return true
				else:
					InfoArray.pop_back()
	
	return false

func RenderMoveComputation(Card,InfoArray):
	for y in range(Dim.y):
		for x in range(Dim.x):
			var index = y*Dim.x+x
			if(Tableau[index].size() > 0):
				for i in range(Tableau[index].size()):
					var c = pow(0.5,Tableau[index].size()-i)
					Tableau[index][i].set_modulate(Color(c,c,c))
	
	
	for i in range(InfoArray.size()):
		var index = InfoArray[i].y*Dim.x+InfoArray[i].x
		for k in range(Tableau[index].size()):
			var c = pow(0.9,Tableau[index].size()-1-k)
			Tableau[index][k].set_modulate(Color(c,c,c))
		if(i < InfoArray.size()-1):
			
			
			var text = str(i)
			if(i < 10):
				text = "0" + text
			
			if(Tableau[index].size() > 0):
				var CurrentCard = Tableau[index][Tableau[index].size()-1]
				
				CurrentCard.get_node("Path").show()
				CurrentCard.get_node("Path/Label").set_text(text)
			
			var Matching = FindMatchingInDir(Card,InfoArray[i],InfoArray[i+1]-InfoArray[i])
			Matching.get_node("Star").show()
			Matching.set_modulate(Color(1,1,1))
	
	




func TernarySign(a):
	var Result = 0
	if(a < 0):
		Result = -1
	elif(a > 0):
		Result = 1
	return Result





#assumes pile at pos has cards
func CardCanMove(Tableau,Pos):
	var index = Pos.y*Dim.x+Pos.x
	var FirstCard = Tableau[index][Tableau[index].size()-1].CardInfo
	var BoardRect = Rect2(0,0,Dim.x-0.5,Dim.y-0.5)
	
	if(BoardRect.has_point(Pos+Vector2(0,-1))):
		if(Tableau[(Pos.y-1)*Dim.x+Pos.x].size()>0):
			for i in range(Pos.y-1,-1,-1):
				var SecondIndex = (i)*Dim.x+Pos.x
				if(Tableau[SecondIndex].size()>0):
					var SecondCard = Tableau[SecondIndex][Tableau[SecondIndex].size()-1].CardInfo
					if(Match(FirstCard,SecondCard)):
						return true
	
	if(BoardRect.has_point(Pos+Vector2(0,1))):
		if(Tableau[(Pos.y+1)*Dim.x+Pos.x].size()>0):
			for i in range(Pos.y+1,Dim.y):
				var SecondIndex = (i)*Dim.x+Pos.x
				if(Tableau[SecondIndex].size()>0):
					var SecondCard = Tableau[SecondIndex][Tableau[SecondIndex].size()-1].CardInfo
					if(Match(FirstCard,SecondCard)):
						return true
	
	if(BoardRect.has_point(Pos+Vector2(-1,0))):
		if(Tableau[Pos.y*Dim.x+Pos.x-1].size()>0):
			for i in range(Pos.x-1,-1,-1):
				var SecondIndex = Pos.y*Dim.x+i
				if(Tableau[SecondIndex].size()>0):
					var SecondCard = Tableau[SecondIndex][Tableau[SecondIndex].size()-1].CardInfo
					if(Match(FirstCard,SecondCard)):
						return true
	
	if(BoardRect.has_point(Pos+Vector2(1,0))):
		if(Tableau[Pos.y*Dim.x+Pos.x+1].size()>0):
			for i in range(Pos.x+1,Dim.x):
				var SecondIndex = Pos.y*Dim.x+i
				if(Tableau[SecondIndex].size()>0):
					var SecondCard = Tableau[SecondIndex][Tableau[SecondIndex].size()-1].CardInfo
					if(Match(FirstCard,SecondCard)):
						return true
	
	return false

func GameCanContinue(Tableau):
	for y in range(Dim.y):
		for x in range(Dim.x):
			if(Tableau[y*Dim.x+x].size()>0):
				if(CardCanMove(Tableau,Vector2(x,y))):
					return true
	
	return false


func UndoMove(Tableau,Waste,UndoArray):
	RegularTweens.remove_all()
	#each entry of undoarray is organized by:
	#1. The card object
	#2. the current place its in
	#3. where it previously was
	if(UndoArray.size() == 1):
		Tableau[UndoArray[0][1]].pop_back()
		Tableau[UndoArray[0][2]].append(UndoArray[0][0])
		UndoArray[0][0].Animating = true
		UndoArray[0][0].set_z_index(10)
		var IndexPos = Vector2(convert(UndoArray[0][2],TYPE_INT)%convert(Dim.x,TYPE_INT),convert(UndoArray[0][2],TYPE_INT)/convert(Dim.x,TYPE_INT))
		var pos = Vector2((IndexPos.x+0.5)*Increment.x,(IndexPos.y+0.5)*Increment.y)
		RegularTweens.interpolate_property(UndoArray[0][0],"position",UndoArray[0][0].get_position(),pos,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	elif(UndoArray.size() == 2):
		Waste.pop_back()
		Tableau[UndoArray[1][2]].append(UndoArray[1][0])
		UndoArray[1][0].set_texture(UndoArray[1][0].FaceUpTexture)
		Waste.pop_back()
		Tableau[UndoArray[0][2]].append(UndoArray[0][0])
		UndoArray[0][0].set_texture(UndoArray[0][0].FaceUpTexture)
		UndoArray[0][0].Animating = true
		UndoArray[1][0].Animating = true
		UndoArray[0][0].set_z_index(10)
		UndoArray[1][0].set_z_index(10)
		var IndexPos = Vector2(convert(UndoArray[0][2],TYPE_INT)%convert(Dim.x,TYPE_INT),convert(UndoArray[0][2],TYPE_INT)/convert(Dim.x,TYPE_INT))
		var pos = Vector2((IndexPos.x+0.5)*Increment.x,(IndexPos.y+0.5)*Increment.y)
		RegularTweens.interpolate_property(UndoArray[0][0],"position",UndoArray[0][0].get_position(),pos,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		IndexPos = Vector2(convert(UndoArray[1][2],TYPE_INT)%convert(Dim.x,TYPE_INT),convert(UndoArray[1][2],TYPE_INT)/convert(Dim.x,TYPE_INT))
		pos = Vector2((IndexPos.x+0.5)*Increment.x,(IndexPos.y+0.5)*Increment.y)
		RegularTweens.interpolate_property(UndoArray[1][0],"position",UndoArray[1][0].get_position(),pos,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	RegularTweens.start()
	UndoArray.clear()
	
	SaveGame()


func HighlightMoves():
	for y in range(Dim.y):
		for x in range(Dim.x):
			var index = y*Dim.x+x
			if(Tableau[index].size()>0):
				if(not CardCanMove(Tableau,Vector2(x,y))):
					for i in range(Tableau[index].size()):
						var c = pow(0.5,Tableau[index].size()-i)
						Tableau[index][i].set_modulate(Color(c,c,c))

func _process(delta):
	
	
	
	if(not ScreenIsTouched):
		mousepos = get_global_mouse_position()
		LMB = Input.is_action_pressed("Select")
	
	ScreenIsTouched = false
	
	var RMB 
	if(not ShowMoves):
		RMB = Input.is_action_pressed("Moves")
	else:
		RMB = true
	
	if(Input.is_action_just_pressed("NewGame")):
		get_node("Menu/NewGame")._on_NewGame_pressed()
	
	
	
	if(Input.is_action_just_pressed("undo")):
		UndoMove(Tableau,Waste,Undo)
	
	var InDeck = true
	for card in Waste:
		if(card.Animating):
			InDeck = false
			break
	
	
	if(Waste.size() == TotalCards and InDeck):
		
		save_file("","user://gridlock.sav")
		
		
		for card in Waste:
			card.set_texture(card.FaceDownTexture)
		var Win = get_node("Win")
		Win.remove_all()
		Undo.clear()
		var Center = Vector2(3.5*Increment.x,3.5*Increment.y)
		get_node("victory").show()
		for i in range(Waste.size()):
			var angle = (-convert(i,TYPE_REAL)/convert(TotalCards,TYPE_REAL)) * 2.0 * PI
			var NewPos = 200.0*Vector2(cos(angle),sin(angle)) + Center
			var Delay = 0.0625 * (TotalCards-i-1)
			Waste[i].Animating = true
			Waste[i].set_z_index(i-Waste.size())
			Win.interpolate_property(Waste[i], "position",Waste[i].get_position(),NewPos,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT,Delay)
		
		Win.start()
	
	#if(not GameCanContinue(Tableau) and Waste.size() != TotalCards and MovingCard.size() == 0):
	#	#put message here
	#	print("You lost.")
	
	
	
	for y in range(Dim.y):
		for x in range(Dim.x):
			var index = y*Dim.x+x
			var pos = Vector2((x+0.5)*Increment.x,(y+0.5)*Increment.y)
			for k in range(Tableau[index].size()):
				if(not Tableau[index][k].Animating):
					var c = pow(0.9,Tableau[index].size()-1-k)
					Tableau[index][k].set_position(pos+Vector2(k*25.0*CardScale.x,0))
					Tableau[index][k].set_z_index(k-100)
					Tableau[index][k].set_modulate(Color(c,c,c))
				Tableau[index][k].get_node("Path").hide()
				Tableau[index][k].get_node("Star").hide()
	
	
	for i in range(Waste.size()):
		if(not Waste[i].Animating):
			Waste[i].set_position(Vector2((Empty.x + 0.5)*Increment.x,(Empty.y+0.5)*Increment.y) + Vector2(i,i))
			Waste[i].set_texture(Waste[i].FaceDownTexture)
			Waste[i].set_z_index(i-Waste.size())
	
	if(MovingCard.size() == 0):
		
		
		if(RMB):
			HighlightMoves()
		
		var PileIndex = -1
		var Coords = Vector2(-1,-1)
		for y in range(Dim.y):
			for x in range(Dim.x):
				var index = y*Dim.x+x
				if(Tableau[index].size() > 0):
					var CardIndex = Tableau[index].size() - 1
					var CardSize = Vector2(CardTextureSize.x * CardScale.x,CardTextureSize.y * CardScale.y) 
					var Rect = Rect2(Tableau[index][CardIndex].position - 0.5 * CardSize, CardSize)
					if(Rect.has_point(mousepos)):
						PileIndex = index
						Coords = Vector2(x,y)
						break
			if(PileIndex != -1):
				break
		
		if(PileIndex != -1):
			var CardIndex = Tableau[PileIndex].size() - 1
			if(not PreviousLMB and LMB):
				MovingCard.append(Tableau[PileIndex][CardIndex])
				MovingCard.append(PileIndex)
				MovingCard.append(Coords)
				Tableau[PileIndex].pop_back()
				MovingCard[0].set_offset(mousepos - MovingCard[0].get_position())
				MovingCard[0].set_z_index(10)
		
	else:
		
		
		var CardSize = Vector2(CardTextureSize.x * CardScale.x,CardTextureSize.y * CardScale.y) 
		var MovingCardRect = Rect2(MovingCard[0].position - 0.5 * CardSize,CardSize)
		var PileIndex = -1
		var Coords = Vector2(-1,-1)
		var MinArea = 30.0
		for y in range(Dim.y):
			for x in range(Dim.x):
				var index = y*Dim.x+x
				if(Tableau[index].size() > 0):
					var CardIndex = Tableau[index].size() - 1
					var Rect = Rect2(Tableau[index][CardIndex].position - 0.5 * CardSize, CardSize)
					var ClipRect = Rect.clip(MovingCardRect)
					if(ClipRect.get_area() > MinArea):
						MinArea = ClipRect.get_area()
						PileIndex = index
						Coords = Vector2(x,y)
		
		
		
		if(LMB):
			MovingCard[0].set_position(mousepos)
			if(PileIndex != -1): #TODO(ian): maybe put some indication of what card the player selected
				Tableau[PileIndex][Tableau[PileIndex].size()-1].set_modulate(Color(0.3,0.3,1.0))
				var Info = [MovingCard[2]]
				if(not IsPositionViable(MovingCard[0],MovingCard[2],Coords,Info)):
					Info.clear()
					Info.append(MovingCard[2])
				else:
					print("Position is Viable for " + str(Coords))
				RenderMoveComputation(MovingCard[0],Info)
		else:
			if(PileIndex == -1): #NOTE(ian): if hovering over empty space
				MovingCard[0].set_z_index(-100)
				MovingCard[0].set_offset(Vector2(0,0))
				Tableau[MovingCard[1]].append(MovingCard[0])
				MovingCard.clear()
			else:
				
				if(IsPositionViable(MovingCard[0],MovingCard[2],Coords,[MovingCard[2]])): #inside here is a valid move!!!
					Undo.clear()
					var SecondCard = Tableau[PileIndex][Tableau[PileIndex].size()-1].CardInfo
					if(Match(MovingCard[0].CardInfo,SecondCard)):
						MovingCard[0].set_position(MovingCard[0].get_position()+MovingCard[0].get_offset())
						MovingCard[0].set_offset(Vector2(0,0))
						Waste.append(Tableau[PileIndex][Tableau[PileIndex].size()-1])
						Undo.append([Waste[Waste.size()-1],Waste.size()-1,PileIndex])
						Waste.append(MovingCard[0])
						Undo.append([MovingCard[0],Waste.size()-1,MovingCard[1]])
						RegularTweens.remove_all()
						var card = Tableau[PileIndex][Tableau[PileIndex].size()-1]
						card.Animating = true
						MovingCard[0].Animating = true
						var wastepos = Vector2((Empty.x + 0.5)*Increment.x,(Empty.y+0.5)*Increment.y) + Vector2(Waste.size()-2,Waste.size()-2)
						RegularTweens.interpolate_property(card,"position",card.get_position(),wastepos,0.25,Tween.TRANS_SINE,Tween.EASE_OUT)
						wastepos = wastepos + Vector2(1,1)
						RegularTweens.interpolate_property(MovingCard[0],"position",MovingCard[0].get_position(),wastepos,0.25,Tween.TRANS_SINE,Tween.EASE_OUT)
						RegularTweens.start()
						
						MovingCard.clear()
						Tableau[PileIndex].pop_back()
					else:
						MovingCard[0].set_z_index(-100)
						MovingCard[0].set_offset(Vector2(0,0))
						Tableau[PileIndex].append(MovingCard[0])
						Undo.append([MovingCard[0],PileIndex,MovingCard[1]])
						MovingCard.clear()
					SaveGame()
					
				else:
					MovingCard[0].set_z_index(-100)
					MovingCard[0].set_offset(Vector2(0,0))
					Tableau[MovingCard[1]].append(MovingCard[0])
					MovingCard.clear()
	
	
	PreviousLMB = LMB
	PreviousRMB = RMB

func _on_Tween_tween_completed(object, key):
	object.Animating = false




func _on_Win_tween_completed(object, key):
	var pos = object.get_position()
	var Center = Vector2(3.5*Increment.x,3.5*Increment.y)
	pos -= Center
	var Win = get_node("Win")
	if(pos.length() < 50.0):
		for i in range(Waste.size()):
			if(object == Waste[i]):
				var angle = (-convert(i,TYPE_REAL)/convert(TotalCards,TYPE_REAL)) * 2.0 * PI
				var NewPos = 200.0*Vector2(cos(angle),sin(angle)) + Center
				var Delay = (convert((TotalCards - i-1),TYPE_REAL) / convert(TotalCards,TYPE_REAL)) * 0.75
				Win.interpolate_property(Waste[i], "position",Waste[i].get_position(),NewPos,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
				break
	else:
		for i in range(Waste.size()):
			if(object == Waste[i]):
				var angle = (-convert(i,TYPE_REAL)/convert(TotalCards,TYPE_REAL)) * 2.0 * PI
				var Delay = (convert((TotalCards - i-1),TYPE_REAL) / convert(TotalCards,TYPE_REAL)) * 0.75
				Win.interpolate_property(object,"position",object.get_position(),Center,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
				break
		
	
	Win.start()
