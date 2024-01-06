extends CharacterBody2D

var speed = 400
var toward #1 is right, -1 is left
var collision = false


#Moving forward
func _process(delta):
	var velocity = Vector2.UP.rotated(PI/2)*speed
	position += velocity*delta*toward
	
	if collision:
		destroy()


func _on_get_collision_position_body_entered(body):
	body.collision = true
	collision = true

func destroy():
	queue_free()


func _on_wall_detection_body_entered(body):
	collision = true
