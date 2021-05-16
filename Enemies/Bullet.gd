extends KinematicBody2D

var direction_to_move = Vector2.ZERO
const SPEED = 7000

func init(dir:Vector2):
	direction_to_move = dir

func _physics_process(delta):
	move_and_slide(direction_to_move * SPEED * delta)
	
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		queue_free()
