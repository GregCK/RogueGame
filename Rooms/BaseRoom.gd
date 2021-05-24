extends Node2D


const SmokePuff = preload("res://Effects/SmokePuff.tscn")

const Dummy = preload("res://Enemies/Dummy.tscn")
const Bat = preload("res://Enemies/Bat.tscn")
const Eyestalker = preload("res://Enemies/EyeStalker.tscn")
const Bouncer = preload("res://Enemies/Bouncer.tscn")
const Pig = preload("res://Enemies/Pig.tscn")
const ShieldPig = preload("res://Enemies/ShieldPig.tscn")

const Grass = preload("res://World/Grass.tscn")
const Bush = preload("res://World/Bush.tscn")
const Tree = preload("res://World/Tree.tscn")
const Rock = preload("res://World/Rock.tscn")
const Exploding_Barrel = preload("res://World/ExplodingBarrel.tscn")
const Items = [Bush, Tree]


var Insides = []
const Inside_Hole = preload("res://World/Inside_Special/Inside Hole.tscn")

func preload_inside_folder():
	var path = "res://World/Insides/"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif !file_name.begins_with("."):
			Insides.append(load(path + file_name))
	dir.list_dir_end()

const Door = preload("res://World/Door.tscn")
const Room = preload("res://World/DirtCliffTileMap.tscn")
const RoomCamera = preload("res://Rooms/RoomCamera.tscn")


onready var playerDetectionZone = $RoomPlayerDetector
#onready var generatedThings = $GeneratedThings
#onready var enemiesNode = $GeneratedThings/EnemiesNode
onready var spawnPositions = $SpawnPositions
onready var topPos = $SpawnPositions/Top
onready var rightPos = $SpawnPositions/Right
onready var bottomPos = $SpawnPositions/Bottom
onready var leftPos = $SpawnPositions/Left
onready var middlePos = $SpawnPositions/Middle
onready var spawnPosArray = [topPos, rightPos, bottomPos, leftPos, middlePos]

const spawnMinX = 32
const spawnMaxX = 32 * 9
const spawnMinY = 32
const spawnMaxY = 32 * 5

var enemyCount = 0
var doorArray = []
var enemyArray = []


enum{
	INITIAL,
	REGULAR,
	END
}

var roomType = REGULAR
var initialRoom:bool
var endRoom:bool = false
var roomEmpty = false


var rng = RandomNumberGenerator.new()

#doors
var hasDoor = [4]

#coordinatesInFloor:
var x
var y

var Floor
var FloorsYSort

var enemyDictionary = {
	"Bat": Bat,
	"Eyestalker": Eyestalker,
	"Bouncer": Bouncer,
	"Pig": Pig,
	"ShieldPig": ShieldPig,
	"Dummy": Dummy
}


var doorPosDictionary = {
	0: [32 * 5 + 16, 0 + 16], #UP
	1: [32 * 10 + 16, 32 * 3 + 16], #RIGHT
	2: [32 * 5 + 16, 32 * 6 + 16], #DOWN
	3: [0 + 16, 32 * 3 + 16] #LEFT
}


#code generated nodes
var myRoomCam
var generatedThings
var enemiesNode

var enemySpawnTimer


var itemsGrid = []
const ITEMS_GRID_WIDTH = (9 * 2) - 1
const ITEMS_GRID_HEIGHT = (5 * 2) - 1
const CELL_SIZE = 16
const gridOffset = 32

# Called when the node enters the scene tree for the first time.
func _ready():
	preload_inside_folder()
	
	
	
	#	create the itemsGrid 2D array
	for i in ITEMS_GRID_WIDTH + 1:
		itemsGrid.append([])
		for j in ITEMS_GRID_HEIGHT + 1:
			itemsGrid[i].append(null) 
	
	
	enemySpawnTimer = Timer.new()
	enemySpawnTimer.set_one_shot(true)
	enemySpawnTimer.connect("timeout", self, "activate_enemies")
	add_child(enemySpawnTimer)
	
	generatedThings = YSort.new()
	add_child(generatedThings)
	enemiesNode = YSort.new()
	generatedThings.add_child(enemiesNode)
	
	myRoomCam = RoomCamera.instance()
	add_child(myRoomCam)
	myRoomCam.position.x += 180
	myRoomCam.position.y += 110
	
	spawn_interior()
	
#	reference the player with playerDetectionZone.player
	playerDetectionZone.connect("detectedPlayer", self, "spawn_doors")
	playerDetectionZone.connect("detectedPlayer", self, "entered_new_combat_room")
	playerDetectionZone.connect("detectedPlayer", self, "set_camera")
	
	doorArray.resize(4)
	
	
	spawn_enemies()


func spawn_interior():
	rng.randomize()


	spawn_inside()
	spawn_object("Exploding_Barrel", 1)

#	var rocks_to_spawn = rng.randi_range(5, 40)
#	spawn_object("Rock", rocks_to_spawn)
#
#
	var grass_to_spawn = rng.randi_range(20, 40)
	spawn_object("Grass", grass_to_spawn)

func spawn_inside():
	var inside = null
	match roomType:
		REGULAR:
			var index = rng.randi_range(0, Insides.size() - 1)
			inside = Insides[index].instance()
		INITIAL:
			inside = Insides[0].instance()
		END:
			inside = Inside_Hole.instance()
	
	
	var xpos = 0
	var ypos = 0
	var inside_pos = Vector2(xpos, ypos)
	inside.position = inside_pos
	
	add_child(inside)

func spawn_object(object_name, amount):
	var object = null
	match object_name:
		"Rock":
			object = Rock
		"Grass":
			object = Grass
		"Exploding_Barrel":
			object = Exploding_Barrel
		_:
			push_error("invalid object name")
	
	
	var i = 0
	while i < amount:
		var xindex = rng.randi_range(0, ITEMS_GRID_WIDTH)
		var yindex = rng.randi_range(0, ITEMS_GRID_HEIGHT)
		
		if itemsGrid[xindex][yindex] != null:
			continue
		
		var new_thing = object.instance()
		
		var xpos = (xindex * CELL_SIZE) + gridOffset
		var ypos = (yindex * CELL_SIZE) + gridOffset
		
		var thing_pos = Vector2(xpos,ypos)
		new_thing.position = thing_pos
		
		generatedThings.add_child(new_thing)
		itemsGrid[xindex][yindex] = new_thing
		
		i += 1


func entered_new_combat_room():
	create_smoke_effect()
	enemySpawnTimer.start(0.6)
	set_player_position()




func set_player_position():
	var player = playerDetectionZone.player
	var playerPos = player.get_global_position()
	var smallestDistance = 999999
	var closestPoint = middlePos
	for pos in spawnPosArray:
		var newDistance = playerPos.distance_to(pos.get_global_position())
		if newDistance < smallestDistance:
			smallestDistance = newDistance
			closestPoint = pos

	player.set_global_position(closestPoint.get_global_position())









func spawn_enemies():
	var enemeiesArray = []

	for i in range(0):
		enemeiesArray.append("Eyestalker")
		
	for i in range(1):
		enemeiesArray.append("Bat")
		
	for i in range(0):
		enemeiesArray.append("Bouncer")
		
	for i in range(0):
		enemeiesArray.append("Pig")
		
	for i in range(0):
		enemeiesArray.append("ShieldPig")
	
	
	if initialRoom:
		spawn_enemy("Dummy")
	
	if roomType == REGULAR and !roomEmpty:
		for i in range(enemeiesArray.size()):
#			spawn_enemy("Eyestalker")
			spawn_enemy(enemeiesArray[i])
			enemyCount += 1



func init(room_type, x, y, doorArray):
	roomType = room_type
	if room_type == INITIAL:
		initialRoom = true
	if initialRoom:
		roomEmpty = true
	self.x = x
	self.y = y

	hasDoor = doorArray




func set_camera():
	myRoomCam._set_current(true) 


func create_smoke_effect():
	for enemy in enemyArray:
		if enemy != null:
			var smokePuff = SmokePuff.instance()
			add_child(smokePuff)
			smokePuff.global_position = enemy.global_position

func activate_enemies():
	for enemy in enemyArray:
		if enemy != null and enemy.has_method("set_active"):
			enemy.set_active(true)
			enemy.set_player(playerDetectionZone.player)
			

func spawn_doors():
	if !roomEmpty and roomType == REGULAR:
		for i in range(4):
			if hasDoor[i]:
				doorArray[i] = spawn_door(doorPosDictionary[i][0], doorPosDictionary[i][1])


func spawn_door(x,y):
	var door = Door.instance()
	generatedThings.call_deferred("add_child", door)
	var door_pos = Vector2(x,y)
	door.position = door_pos
	return door


func spawn_enemy(enemyName:String):
	var enemy = enemyDictionary[enemyName].instance()
	if enemy.has_signal("reportDeath"):
		enemy.connect("reportDeath", self, "decrementEnemyCount")
	enemiesNode.add_child(enemy)
#	enemiesNode.call_deferred("add_child", enemy)
	enemyArray.append(enemy)
	while true:
		var xpos = rand_range(spawnMinX,spawnMaxX)
		var ypos = rand_range(spawnMinY, spawnMaxY)
		var enemy_pos = Vector2(xpos,ypos)
		enemy.position = enemy_pos
		var enemyColls = enemy.test_move(enemy.transform, Vector2.UP)
		if !enemyColls:
			return
		else:
			continue


func decrementEnemyCount():
	enemyCount -= 1
	if enemyCount <= 0:
		print("no enemies, open doors")
		roomEmpty = true
		for i in range(4):
			if doorArray[i] != null:
				doorArray[i].queue_free()




##adds new room via new DirtCliffTileMap
#func add_new_room(roomNum,x,y):
##	var room = rooms[roomNum].instance()
#	var room = Room.instance()
#	add_child(room)
#	var position = Vector2(x,y)
#	room.global_position = position

