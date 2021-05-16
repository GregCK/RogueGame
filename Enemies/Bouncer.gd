extends "res://Enemies/Enemy.gd"


const FRICTION = 400
const MAX_SPEED = 100
export var ACCELERATION = 300


onready var animationPlayer = $AnimationPlayer
onready var groundedTimer = $GroundedTimer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var softCollision = $SoftCollision

enum{
	INACTIVE,
	BOUNCE,
	GROUNDED
}

var state = INACTIVE
var activeState = GROUNDED

var player_location_at_jump_start:Vector2

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		INACTIVE:
			pass
		GROUNDED:
			grounded_state(delta)
		BOUNCE:
			bounce_state(delta)
		
	
	
	if softCollision.is_colliding():
		velocity = velocity + (softCollision.get_push_vector() * delta * 400)
	velocity = move_and_slide(velocity)

var vec_to_last_grounded_player_pos = Vector2.RIGHT

func grounded_state(delta):
	animationPlayer.play("Grounded")
	velocity = Vector2.ZERO
	
	
	


func bounce_state(delta):
	if player != null:
		vec_to_last_grounded_player_pos = (player_location_at_jump_start - global_position)
	vec_to_last_grounded_player_pos = vec_to_last_grounded_player_pos.normalized()
	velocity = velocity.move_toward(vec_to_last_grounded_player_pos * MAX_SPEED, ACCELERATION * delta)
#	velocity = vec_to_last_grounded_player_pos

func set_active(isActive:bool):
	if isActive:
		hurtboxCollisionShape.set_deferred("disabled", false)
		state = activeState
		groundedTimer.start(1)
	else:
		hurtboxCollisionShape.set_deferred("disabled", true)
		state = INACTIVE

func bounce_animation_ended():
	state = GROUNDED
	groundedTimer.start(1)


func _on_GroundedTimer_timeout():
	player_location_at_jump_start = player.get_global_position() 
	state = BOUNCE
	animationPlayer.play("Bounce")


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
	blinkAnimationPlayer.play("Stop")


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")
