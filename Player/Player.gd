extends KinematicBody2D


const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 100
const ROLL_SPEED = 300


enum{
	MOVE,
	ROLL,
	ATTACK,
	STUN
}

var state = MOVE
var canDash = true


var velocity = Vector2.ZERO
var rollVector = Vector2.DOWN
var stats = PlayerStats

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

onready var animationPlayer = $AnimationPlayer

onready var sword = $HitboxPivot/Sword
onready var swordHitBox = $HitboxPivot/Sword/SwordHitBox
onready var swordCollisionShape = $HitboxPivot/Sword/SwordHitBox/CollisionShape2D
onready var swordAnimationTree = $HitboxPivot/Sword/AnimationTree

onready var hurtbox = $Hurtbox
onready var hurtboxCollisionShape = $Hurtbox/CollisionShape2D
onready var sprite = $Sprite

onready var dashTimer = $DashTimer
onready var stunTimer = $StunTimer

onready var blinkAnimationPlayer = $BlinkAnimationPlayer #for taking damage
onready var blinkAnimationPlayer2 = $BlinkAnimationPlayer2 #for being stunned

onready var shieldHitSound = $ShieldHitSound


func _ready():
	
	stats.connect("no_health", self, "queue_free")
	stats.connect("no_health", self, "restart_game")
	swordHitBox.knockback_vector = rollVector
	swordHitBox.connect("stun_player", self, "stun")
	stunTimer.connect("timeout", self, "end_stun")

func restart_game():
	var path = "res://World/Surface.tscn"
	SceneChanger.change_scene(path)

func stun():
	state = STUN
	stunTimer.start(1)
#	swordCollisionShape.disabled = true
	swordCollisionShape.set_deferred("disabled", true)
	animationPlayer.play("Stun")
	shieldHitSound.play()
	blinkAnimationPlayer2.play("Start")




func end_stun():
	state = MOVE
	blinkAnimationPlayer2.play("Stop")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
		STUN:
			pass


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var sword_animation_vector = input_vector
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		rollVector = input_vector
		swordHitBox.knockback_vector = rollVector
		set_flip(input_vector)
		swordAnimationTree.set("parameters/Attack/blend_position", input_vector)
		swordHitBox.direction = input_vector
		animationPlayer.play("Run")
		if !Input.is_action_pressed("hold"):
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO * MAX_SPEED, ACCELERATION * delta)
			animationPlayer.play("Idle")
	else:
#		animationState.travel("Idle")
		animationPlayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll") and canDash:
		state = ROLL
	
	
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	hurtboxCollisionShape.disabled = true
	velocity = rollVector * ROLL_SPEED
	move()
#	animationState.travel("Roll")
	animationPlayer.play("Roll")
	canDash = false
	dashTimer.start()
	

func attack_state(delta):
	
	
	if sword.attack():
		velocity = velocity / 2
		animationPlayer.play("Attack")
	
	
	

func move():
	velocity = move_and_slide(velocity)


func set_flip(input_vector):
	if input_vector.x < 0:
		sprite.set_flip_h(true)
	elif input_vector.x > 0:
		sprite.set_flip_h(false)


func attack_animation_finished():
	
	
	
	if state != STUN:
		animationPlayer.play("Run")
		state = MOVE
	


func roll_animation_finished():
	hurtboxCollisionShape.disabled = false
	velocity = velocity / 4
	state = MOVE



func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(1)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)






func _on_DashTimer_timeout():
	canDash = true


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
