extends KinematicBody2D


onready var hurtbox = $Hurtbox
onready var hurtboxCollisionShape = $Hurtbox/CollisionShape2D
onready var stats = $Stats

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
signal reportDeath

var player

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_player(p):
	player = p


