extends CharacterBody2D


const SPEED = 1.0

var detect_player = false
var hp = 1
var die = false

func _physics_process(delta):
	

	move_and_slide()


func _on_player_detection_body_entered(body):
	detect_player = true
	#attack(body.position)

func attack(pos):
	
	var hypo = sqrt((pos.x - position.x)*(pos.x - position.x) + (pos.y - position.y)*(pos.y - position.y))
	var x
	var y
	

	x = SPEED*(pos.x - position.x)/hypo
	y = SPEED*(pos.y - position.y)/hypo
	
	if is_on_floor():
		y -= 2*abs((pos.y - position.y)/hypo)
	position += Vector2(x, y)


func _on_bullet_detection_body_entered(body):
	hp -= 1
	print("Got shot")
	if hp <= 0:
		die = true

func destroy():
	queue_free()
