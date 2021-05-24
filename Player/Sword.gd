extends Node2D

onready var swordHitBox = $SwordHitBox
onready var swordSprite = $SwipeSprite
onready var swordAnimationTree = $AnimationTree
onready var swordAnimationPlayer = $AnimationPlayer
onready var swordAnimationState = swordAnimationTree.get("parameters/playback")
onready var swordTimer = $SwordTimer
onready var swordSound1 = $SwordSound1
onready var swordSound2 = $SwordSound2

signal attack_done

var isAttacking = false
var swingNumber = 0

func _ready():
	swordAnimationTree.active = true

func attack():
	if !isAttacking:
		isAttacking = true
		swordAnimationState.travel("Attack")
		
		swingNumber += 1
		var remain = fmod(swingNumber, 2)
		if remain == 0:
			swordSound1.play()
			swordSprite.set_flip_v(true)
		else:
			swordSound2.play()
			swordSprite.set_flip_v(false)
		
		
		return true
	else:
		return false
		


func attack_animation_finished():
	emit_signal("attack_done")
	isAttacking = false
	swordAnimationState.travel("Idle")
	swordTimer.start(1)




func _on_SwordTimer_timeout():
	swingNumber = 0
