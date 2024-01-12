extends CharacterBody2D


const SPEED = 1.0

@onready var player_location = $"../Player"
var detect_player = false
var hp = 1
var collision

func _ready():
	$AnimatedSprite2D.play("idle")

func _physics_process(_delta):
	if detect_player:
		attack(player_location.position)
	move_and_slide()


func _on_player_detection_body_entered(_body):
	detect_player = true


func attack(pos):
	
	var hypo = sqrt((pos.x - position.x)*(pos.x - position.x) + (pos.y - position.y)*(pos.y - position.y))
	var x
	var y
	

	x = SPEED*(pos.x - position.x)/hypo
	y = SPEED*(pos.y - position.y)/hypo
	
	if is_on_floor():
		y -= 2*abs((pos.y - position.y)/hypo)
	
	position += Vector2(x, y)
	update_animation(x)


func update_animation(direction):
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	

func _on_bullet_detection_body_entered(body):
	hp -= 1
	body.collision = true
	if hp <= 0:
		detect_player = false
		$AnimatedSprite2D.play("dead")


func destroy():
	queue_free()


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "dead":
		destroy()
