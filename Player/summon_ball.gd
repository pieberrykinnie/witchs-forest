extends CharacterBody2D

var speed = 400
var toward #1 is right, -1 is left
var collision = false


#Moving forward
func _process(delta):
	var velocity = Vector2.UP.rotated(PI/2)*speed
	position += velocity*delta*toward
	




func _on_collision_happens_body_entered(body):
	queue_free()



func _on_get_collision_position_body_entered(body):
	collision = true
	#print(position)
