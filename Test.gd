extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	var list = []
	rng.randomize()
	var num = rng.randfn(0.0, 1.0)
	for i in range(100):
		list.append(int(rng.randfn(0.0, 1.0)))
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
