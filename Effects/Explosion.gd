extends Node2D


onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("Explode")


func animation_finished():
	queue_free()


func _on_Hitbox_area_entered(area):
	var parent = area.get_parent() #shieldside
	var grandparent = area.get_parent() #shield
	if grandparent.name == "Shield":
		parent.remove()
