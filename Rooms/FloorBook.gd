extends Node2D

const Player = preload("res://Player/Player.tscn")

const RoomTop = preload("res://Rooms/Room_Scenes/RoomTopOpen.tscn")
const RoomRight = preload("res://Rooms/Room_Scenes/RoomRightOpen.tscn")
const RoomDown = preload("res://Rooms/Room_Scenes/RoomDownOpen.tscn")
const RoomLeft = preload("res://Rooms/Room_Scenes/RoomLeftOpen.tscn")
const RoomTopRight = preload("res://Rooms/Room_Scenes/RoomTopRightOpen.tscn")
const RoomTopDown = preload("res://Rooms/Room_Scenes/RoomTopDownOpen.tscn")
const RoomTopLeft = preload("res://Rooms/Room_Scenes/RoomTopLeftOpen.tscn")
const RoomRightDown = preload("res://Rooms/Room_Scenes/RoomRightDownOpen.tscn")
const RoomRightLeft = preload("res://Rooms/Room_Scenes/RoomRightLeftOpen.tscn")
const RoomDownLeft = preload("res://Rooms/Room_Scenes/RoomDownLeftOpen.tscn")
const RoomTopClosed = preload("res://Rooms/Room_Scenes/RoomTopClosed.tscn")
const RoomRightClosed = preload("res://Rooms/Room_Scenes/RoomRightClosed.tscn")
const RoomDownClosed = preload("res://Rooms/Room_Scenes/RoomDownClosed.tscn")
const RoomLeftClosed = preload("res://Rooms/Room_Scenes/RoomLeftClosed.tscn")
const RoomAllOpen = preload("res://Rooms/Room_Scenes/RoomAllOpen.tscn")



var player

var rng = RandomNumberGenerator.new()

const room_width = 32 * 11
const room_height = 32 * 7

var floorGrid = []
var floorGridWidth = 12
var floorGidHeight = 12


const AMOUNT_OF_ROOMS = 6
var floorPlaceholderRooms = [] #array of RoomPlaceholders
var floorActualRooms = [] #array of actual Room Nodes

enum{
	TOP, RIGHT, DOWN, LEFT,
	TOPRIGHT, TOPDOWN, TOPLEFT,
	RIGHTDOWN, RIGHTLEFT,
	DOWNLEFT,
	TOPCLOSED, RIGHTCLOSED, DOWNCLOSED, LEFTCLOSED,
	ALLOPEN
}


#var DoorHoleDictionary = {
#	"TOP": Room0
#}

class RoomPlaceholder:
	var x
	var y
	var openingType = ALLOPEN
	
	func _init(xIndex, yIndex):
		x = xIndex
		y = yIndex


var room_resource_array = []

func get_room_resources():
	var path = "res://Rooms/Room_Scenes/"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with("."):
			room_resource_array.append(load(path + file_name))
	dir.list_dir_end()




# Called when the node enters the scene tree for the first time.
func _ready():
	get_room_resources()
	
	
	rng.randomize()
	
#	create the floorGrid 2D array
	for i in floorGridWidth:
		floorGrid.append([])
		for j in floorGidHeight:
			floorGrid[i].append(null) 
			
#	add the initial room in the center
#	add_initial_room(int(floorGridWidth/2), int(floorGidHeight/2) )
	add_initial_placeholder_room(int(floorGridWidth/2), int(floorGidHeight/2) )


	generate_floor_plan(AMOUNT_OF_ROOMS)
	add_rooms()

	add_player()

func generate_floor_plan(amountOfRooms):
	var i = 0
	while i < amountOfRooms:
#		pick a random room
		var randomRoomIndex = rng.randi_range(0, floorPlaceholderRooms.size() - 1)
#		gets its x and y coordinates
		var randomRoomXCoor = floorPlaceholderRooms[randomRoomIndex].x
		var randomRoomYCoor = floorPlaceholderRooms[randomRoomIndex].y
		
#		pick a random direction
		var randomDirection = rng.randi_range(0, 3)
		
		var potencialRoomXCoor = randomRoomXCoor
		var potencialroomYCoor = randomRoomYCoor
		
		match randomDirection:
			0:
				potencialroomYCoor -= 1
			1:
				potencialRoomXCoor += 1
			2:
				potencialroomYCoor += 1
			3:
				potencialRoomXCoor -= 1
			_:
				push_error("needs to be 0-3")
		
#		check to see if the random direction has a potencial room
		if floorGrid[potencialRoomXCoor][potencialroomYCoor] == null:
			var newPlaceHolder = RoomPlaceholder.new(potencialRoomXCoor, potencialroomYCoor)
			floorGrid[potencialRoomXCoor][potencialroomYCoor] = newPlaceHolder
			floorPlaceholderRooms.append(newPlaceHolder)
			i += 1
		else:
			continue


func add_rooms():
	determine_room_opening()
	for i in floorPlaceholderRooms.size():
		if i == 0:
#			add_initial_room(int(floorGridWidth/2), int(floorGidHeight/2))
			add_room(true, floorPlaceholderRooms[i])
		else:
			add_room(false, floorPlaceholderRooms[i])

func determine_room_opening():
	for roomPH in floorPlaceholderRooms:
		var x = roomPH.x
		var y = roomPH.y
		var amountOfHoles = 0
		var up = false
		var right = false
		var down = false
		var left = false
		if floorGrid[x][y-1] != null:
			amountOfHoles += 1
			up = true
		if floorGrid[x+1][y] != null:
			amountOfHoles += 1
			right = true
		if floorGrid[x][y+1] != null:
			amountOfHoles += 1
			down = true
		if floorGrid[x-1][y] != null:
			amountOfHoles += 1
			left = true
		
		
		match amountOfHoles:
			4:
				roomPH.openingType = ALLOPEN
			3:
				if !up:
					roomPH.openingType = TOPCLOSED
				elif !right:
					roomPH.openingType = RIGHTCLOSED
				elif !down:
					roomPH.openingType = DOWNCLOSED
				elif !left:
					roomPH.openingType = LEFTCLOSED
			2:
				if up:
					if right:
						roomPH.openingType = TOPRIGHT
					elif down:
						roomPH.openingType = TOPDOWN
					elif left:
						roomPH.openingType = TOPLEFT
				elif right:
					if down:
						roomPH.openingType = RIGHTDOWN
					elif left:
						roomPH.openingType = RIGHTLEFT
				elif down and left:
					roomPH.openingType = DOWNLEFT
			1:
				if up:
					roomPH.openingType = TOP
				elif right:
					roomPH.openingType = RIGHT
				elif down:
					roomPH.openingType = DOWN
				elif left:
					roomPH.openingType = LEFT



func add_room(isInitialRoom, newRoom:RoomPlaceholder):
#	var randomRoomIndex = rng.randi_range(0, 0) #this will need to be changed so that it selects a room with door holes in the correct spot
	var openType = newRoom.openingType
	var room
	var hasDoors = [true, true, true, true]
	match openType:
		TOP:
			room = RoomTop.instance()
			hasDoors = [true, false, false, false]
		RIGHT:
			room = RoomRight.instance()
			hasDoors = [false, true, false, false]
		DOWN:
			room = RoomDown.instance()
			hasDoors = [false, false, true, false]
		LEFT:
			room = RoomLeft.instance()
			hasDoors = [false, false, false, true]
		TOPRIGHT:
			room = RoomTopRight.instance()
			hasDoors = [true, true, false, false]
		TOPDOWN:
			room = RoomTopDown.instance()
			hasDoors = [true, false, true, false]
		TOPLEFT:
			room = RoomTopLeft.instance()
			hasDoors = [true, false, false, true]
		RIGHTDOWN:
			room = RoomRightDown.instance()
			hasDoors = [false, true, true, false]
		RIGHTLEFT:
			room = RoomRightLeft.instance()
			hasDoors = [false, true, false, true]
		DOWNLEFT:
			room = RoomDownLeft.instance()
			hasDoors = [false, false, true, true]
		TOPCLOSED:
			room = RoomTopClosed.instance()
			hasDoors = [false, true, true, true]
		RIGHTCLOSED:
			room = RoomRightClosed.instance()
			hasDoors = [true, false, true, true]
		DOWNCLOSED:
			room = RoomDownClosed.instance()
			hasDoors = [true, true, false, true]
		LEFTCLOSED:
			room = RoomLeftClosed.instance()
			hasDoors = [true, true, true, false]
		ALLOPEN:
			room = RoomAllOpen.instance()
			hasDoors = [true, true, true, true]
		

	room.init(isInitialRoom, newRoom.x, newRoom.y, hasDoors)

	
	var xCoor = newRoom.x * room_width
	var yCoor = newRoom.y * room_height
	var position = Vector2(xCoor, yCoor)
	room.global_position = position
	
	floorActualRooms.append(room)




func add_initial_placeholder_room(x,y):
	var newPlaceHolder = RoomPlaceholder.new(x,y)
	floorGrid[x][y] = newPlaceHolder
	floorPlaceholderRooms.append(newPlaceHolder)


func change_initial_scene():
	var room = floorActualRooms[0]
	assert(get_tree().change_scene_to(room) == OK)

func change_scene():
	pass

func add_player():
	player = Player.instance()

	
	#	add the player to the center of the initial room
	var roomSizeOffset = Vector2(room_width / 2, room_height / 2)
	player.global_position = floorActualRooms[0].global_position + roomSizeOffset
