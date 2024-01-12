extends CharacterBody2D
class_name Bullet

var speed := 400.0
var speed_vector := Vector2.UP.rotated(PI/2) * speed
var direction
var collision := false

func _ready():
	$AnimatedSprite2D.play("default")

func _process(delta):
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
	position += speed_vector * delta * direction


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_bullet_detection_body_entered(_body):
	$AnimatedSprite2D.play("on_hit")
	direction = 0


func _on_wall_detection_body_entered(_body):
	$AnimatedSprite2D.play("on_hit")
	direction = 0


func _on_animated_sprite_2d_animation_finished():
	if ($AnimatedSprite2D.animation == "on_hit"):
		queue_free()
