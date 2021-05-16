#extends KinematicBody2D
extends "res://Enemies/Enemy.gd"


export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200


enum{
	INACTIVE,
	IDLE,
	WANDER,
	CHASE
}

var state = INACTIVE
var activeState = CHASE

onready var sprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var animationPlayer = $AnimationPlayer



func _ready():
	hurtboxCollisionShape.disabled = true
#	hurtboxCollisionShape.set_deferred("disabled", true)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		INACTIVE:
			pass
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position)
				direction = direction.normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	
	if softCollision.is_colliding():
		velocity = velocity + (softCollision.get_push_vector() * delta * 400)
	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func set_active(isActive:bool):
	if isActive:
		hurtboxCollisionShape.set_deferred("disabled", false)
		state = activeState
	else:
		hurtboxCollisionShape.set_deferred("disabled", true)
		state = INACTIVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_Stats_no_health():
	emit_signal("reportDeath")
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")
