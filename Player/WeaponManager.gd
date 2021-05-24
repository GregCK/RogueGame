extends Node2D


onready var sword = $Sword
onready var swordHitBox = $Sword/SwordHitBox
onready var swordCollisionShape = $Sword/SwordHitBox/CollisionShape2D
onready var swordAnimationTree = $Sword/AnimationTree

onready var knfie = $Knife

onready var weapon_queue = [sword, knfie]
var curr_weapon = 0

func _ready():
	var player = get_parent().get_parent()
	
	for weapon in weapon_queue:
		weapon.connect("attack_done", player, "attack_animation_finished")
		weapon.connect("attack_done", self, "increment_weapon")
		
		var weaponHitBox = weapon.get_node("SwordHitBox")
		weaponHitBox.connect("stun_player", player, "stun")
	#		weapon.connect("attack_finished", self, "increment_weapon")
		weaponHitBox.knockback_vector = Vector2.DOWN


func attack():
	if weapon_queue[curr_weapon].attack():
		return true
	else:
		return false


func set_knockback_vector(new_knockback_vector:Vector2):
#	weaponManager.weaponHitBox.knockback_vector = rollVector
	for weapon in weapon_queue:
		var weaponHitBox = weapon.get_node("SwordHitBox")
		weaponHitBox.knockback_vector = new_knockback_vector

func disabled_collision_shapes():
	for weapon in weapon_queue:
		var weaponCollisionShape = weapon.get_node("SwordHitBox").get_node("CollisionShape2D")
		weaponCollisionShape.set_deferred("disabled", true)


func set_blend_positions(blend_pos):
#	weaponManager.weaponAnimationTree.set("parameters/Attack/blend_position", input_vector)
	for weapon in weapon_queue:
		var animationTree = weapon.get_node("AnimationTree")
		animationTree.set("parameters/Attack/blend_position", blend_pos)

func set_hitbox_direction(new_direction:Vector2):
	for weapon in weapon_queue:
		var weaponHitBox = weapon.get_node("SwordHitBox")
		weaponHitBox.direction = new_direction

func increment_weapon():
	pass
