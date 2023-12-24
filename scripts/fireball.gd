extends CharacterBody2D

var speed := 400.0
var direction

func _process(delta):
	var velocity = Vector2.UP.rotated(PI/2)*speed
	
	position += velocity*delta*direction
