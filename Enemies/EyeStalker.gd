#extends KinematicBody2D
extends "res://Enemies/Enemy.gd"


const MAX_SPEED = 60
const ACCELERATION = 300
const FRICTION = 200

const Bullet = preload("res://Enemies/Bullet.tscn")

onready var moveTimer = $MoveTimer
onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer


var move_dir = Vector2.ZERO

enum{
	INACTIVE,
	MOVE_DIRECTION,
	CHANGE_MOVE_DIRECTION,
	SHOOT
}

var state = INACTIVE
var activeState = CHANGE_MOVE_DIRECTION

var moves = 0


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		INACTIVE:
			pass
			
		MOVE_DIRECTION:
			animationPlayer.play("move")
			velocity = velocity.move_toward(move_dir * MAX_SPEED, ACCELERATION * delta)
			
			
			
		CHANGE_MOVE_DIRECTION:
			var min_x = -1
			var max_x = 1
			var min_y = -1
			var max_y = 1
			move_dir = Vector2(rand_range(min_x, max_x), rand_range(min_y, max_y))
			move_dir = move_dir.normalized()
			
			if moves < 3:
				state = MOVE_DIRECTION
				moves += 1
				var moveTime = rand_range(0.7, 1.5)
				moveTimer.start(moveTime)
			else:
				state = SHOOT
				moveTimer.stop()
				moves = 0
			
		SHOOT:
			velocity = velocity / 3
			animationPlayer.play("shoot")
	
	velocity = move_and_slide(velocity)

func set_active(isActive:bool):
	if isActive:
		hurtboxCollisionShape.set_deferred("disabled", false)
		state = activeState
	else:
		hurtboxCollisionShape.set_deferred("disabled", true)
		state = INACTIVE


var bulletsShot = 0

func shoot_bullet():
	var vec_to_player = Vector2.RIGHT
	if player != null:
		vec_to_player = (player.global_position - global_position)
	vec_to_player = vec_to_player.normalized()
	var bullet = Bullet.instance()
	bullet.init(vec_to_player)
	var world = get_tree().current_scene
	world.add_child(bullet)
	bullet.global_position = global_position
	
	bulletsShot += 1
	if bulletsShot >= 3:
		bulletsShot = 0
		state = CHANGE_MOVE_DIRECTION
		

func _on_Stats_no_health():
	emit_signal("reportDeath")
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_MoveTimer_timeout():
	state = CHANGE_MOVE_DIRECTION




func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
