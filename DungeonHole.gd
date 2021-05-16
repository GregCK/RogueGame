extends StaticBody2D


onready var playerDetectionZone = $PlayerDetectionZone


# Called when the node enters the scene tree for the first time.
func _ready():
	playerDetectionZone.connect("detectedPlayer", self, "create_dungeon")


func create_dungeon():
	FloorBook.change_initial_scene()
