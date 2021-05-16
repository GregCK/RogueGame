extends "res://Hurtboxes + Hitboxes/Hitbox.gd"




var direction = Vector2.ZERO

signal stun_player

func shield_hit():
	emit_signal("stun_player")
