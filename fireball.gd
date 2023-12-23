extends CharacterBody2D

var speed = 400
var toward #1 is right, -1 is left
#Moving forward
func _process(delta):
	var velocity = Vector2.UP.rotated(PI/2)*speed
	
	position += velocity*delta*toward
