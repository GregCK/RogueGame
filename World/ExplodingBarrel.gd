extends KinematicBody2D

const Explosion = preload("res://Effects/Explosion.tscn")

onready var hitBoxCollisionShape = $BarrelHitBox/CollisionShape2D
onready var hitBox = $BarrelHitBox

var moving = false
var velocity = Vector2.ZERO
const MOVE_SPEED = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	hitBoxCollisionShape.disabled = true


func _physics_process(delta):
	if moving:
		velocity = move_and_slide(velocity)


func _on_BarrelHurtBox_area_entered(area):
#	hitBoxCollisionShape.disabled = false
	hitBoxCollisionShape.set_deferred("disabled", false)
	moving = true
	velocity = area.direction * MOVE_SPEED
	hitBox.knockback_vector = area.direction
	


func _on_BarrelHitBox_body_entered(body):
	explode()



func _on_BarrelHitBox_area_entered(area):
	explode()


func explode():
	#	explode!!!
	if moving:
		create_explosion_effect()
		queue_free()

func create_explosion_effect():
		var explosion = Explosion.instance()
		var parent = get_parent().get_parent().get_parent()
#		parent.add_child(explosion)
#		var args = [explosion]
		parent.call_deferred("add_child", explosion)
		explosion.global_position = global_position
