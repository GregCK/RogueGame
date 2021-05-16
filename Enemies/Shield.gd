extends Node2D


onready var frontShield = $FrontShield
onready var frontCollision = $FrontShield/FrontShieldArea/CollisionShape2D

onready var backShield = $BackShield
onready var backShieldSprite = $BackShield/BackShieldSprite
onready var backCollision = $BackShield/BackShieldArea/CollisionShape2D

onready var leftShield = $LeftShield
onready var leftCollision = $LeftShield/LeftShieldArea/CollisionShape2D

onready var rightShield = $RightShield
onready var rightCollision = $RightShield/RightShieldArea/CollisionShape2D

onready var sides = [frontShield, backShield, leftShield, rightShield]

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
#	draw the back shield behind the owner of the shield
	var parent = get_parent()
	var parent_z = parent.get_z_index()
	backShieldSprite.z_index = parent_z - 1
	
	
	var rand_side = rng.randi_range(0,3)
	var i = 0
	for side in sides:
		if i == rand_side:
			set_side_active(side, true)
		else:
			set_side_active(side, false)
		i += 1



func set_side_active(side, value):
	match side:
		frontShield:
			if value:
				frontCollision.disabled = false
				side.visible = true
			else:
				frontCollision.disabled = true
				side.visible = false 
		backShield:
			if value:
				backCollision.disabled = false
				side.visible = true
			else:
				backCollision.disabled = true
				side.visible = false
		leftShield:
			if value:
				leftCollision.disabled = false
				side.visible = true
			else:
				leftCollision.disabled = true
				side.visible = false
		rightShield:
			if value:
				rightCollision.disabled = false
				side.visible = true
			else:
				rightCollision.disabled = true
				side.visible = false
		


func get_direction(area):
	if not area.get("direction") == null:
		return area.direction


func _on_FrontShieldArea_area_entered(area):
	var direction = get_direction(area)
	if direction != null and direction.y <= 0:
		area.shield_hit()


func _on_BackShieldArea_area_entered(area):
	var direction = get_direction(area)
	if direction != null and direction.y >= 0:
		area.shield_hit()


func _on_LeftShieldArea_area_entered(area):
	var direction = get_direction(area)
	if direction != null and direction.x >= 0:
		area.shield_hit()

func _on_RightShieldArea_area_entered(area):
	var direction = get_direction(area)
	if direction != null and direction.x <= 0:
		area.shield_hit()
