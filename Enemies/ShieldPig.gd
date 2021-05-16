extends "res://Enemies/Enemy.gd"

const MAX_SPEED = 60
const ACCELERATION = 300
const FRICTION = 200

enum{
	INACTIVE,
	RUNNING,
	ATTACKING,
	IDLE
}

var state = INACTIVE
var activeState = IDLE

onready var animationPlayer = $AnimationPlayer
onready var rayCast2D = $RayCast2D
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var hitbox = $Position2D/Hitbox


var vec_to_player = Vector2.ZERO


func _ready():
	rayCast2D.enabled = true
	rayCast2D.add_exception(self)
	rayCast2D.set_collide_with_areas(true)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	
	match state:
		INACTIVE:
			pass
		RUNNING:
			if !can_see_player():
				state = IDLE
				animationPlayer.play("Idle")
			
			
			velocity = velocity.move_toward(vec_to_player * MAX_SPEED, ACCELERATION * delta)
			
			set_flip()
			
			if playerDetectionZone.can_see_player():
				state = ATTACKING
				animationPlayer.play("Attack")
#			check to see if raycast can see player and move to player.
#			if can't see, move to idle
#			if in range of player, attack
		ATTACKING:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		IDLE:
			if can_see_player():
				state = RUNNING
				animationPlayer.play("Run")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
#			wait until pig can see player
	
	velocity = move_and_slide(velocity)

func set_flip():
	if velocity.x < 0:
		sprite.set_flip_h(false)
		hitbox.rotation_degrees = 0
	else:
		sprite.set_flip_h(true)
		hitbox.rotation_degrees = 180


func can_see_player():
	vec_to_player = (player.global_position - global_position)
	vec_to_player = vec_to_player.normalized()
	rayCast2D.cast_to = vec_to_player * 9000
	
	if rayCast2D.is_colliding():
		var coll = rayCast2D.get_collider()
		if coll != null:
			if coll.name == "Player" or coll.name == "Hurtbox":
				return true
			else:
				return false
		else:
			return false
	
	

func set_active(isActive:bool):
	if isActive:
		hurtboxCollisionShape.set_deferred("disabled", false)
		state = activeState
		animationPlayer.play("Idle")
	else:
		hurtboxCollisionShape.set_deferred("disabled", true)
		state = INACTIVE


func attack_animation_finished():
	state = IDLE
	animationPlayer.play("Idle")

var takingDamage = false

func _on_Hurtbox_area_entered(area):
#	yield(get_tree(),"idle_frame")
#	var collision = area.get_node("CollisionShape2D")
#	if collision.disabled == false and !takingDamage:
#		takingDamage = true
#		take_damage(area)
	
	take_damage(area)
		

func take_damage(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	takingDamage = false


func _on_Stats_no_health():
	emit_signal("reportDeath")
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
