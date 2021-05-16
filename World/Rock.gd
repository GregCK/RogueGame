extends StaticBody2D

onready var rockSprite = $Sprite

const Rock1 = preload("res://World/Rock1.png")
const Rock2 = preload("res://World/Rock2.png")
const Rock3 = preload("res://World/Rock3.png")
const Rock4 = preload("res://World/Rock4.png")
const Rock5 = preload("res://World/Rock5.png")
const Rock6 = preload("res://World/Rock6.png")

var Rocks = [Rock1, Rock2, Rock3, Rock4, Rock5, Rock6]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var i = rng.randi_range(3,5)
	rockSprite.set_texture(Rocks[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
