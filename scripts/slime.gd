extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var toward = -1
var hp = 3
var collision
var hiding := true

func _ready():
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#Moving toward right or left and change direction if hit the wall
	if not hiding and hp > 0:
		velocity.x += SPEED * toward * delta
	
	update_facing()
	move_and_slide()


func _on_wall_detection_body_entered(_body):
	toward *= (-1)


func update_facing():
	if toward == 1:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	

func unhide(direction_detected):
	if direction_detected.position.x - position.x > 0:
		toward = 1
	hiding = false
	$AnimatedSprite2D.play("unhide")


func _on_bullet_detection_body_entered(body):
	if not hiding:
		hp -= 1
		$AnimatedSprite2D.play("hit")
		velocity.x = 0
		
		if hp <= 0:
			$AnimatedSprite2D.play("death")
			velocity.x = 0
	
	else:
		unhide(body)


func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == "hit"
	or $AnimatedSprite2D.animation == "unhide"):
		$AnimatedSprite2D.play("move")
	elif ($AnimatedSprite2D.animation == "death"):
		queue_free()


func _on_player_detection_body_entered(body):
	if hiding:
		unhide(body)
