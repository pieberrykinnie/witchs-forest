extends CharacterBody2D
class_name Player

signal hit
signal death

@export var speed := 200.0
@export var jump_velocity := -400.0
@export var maxHp := 8


@onready var animated_sprite := $AnimatedSprite2D

const fireball_path = preload("res://scenes/fireball.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var hp := maxHp
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked := false
var falling := false
var off_cooldown := true
var invincible := false
var direction := Vector2.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	else:
		if falling:
			animated_sprite.play("jump_end")
			falling = false

	move_and_slide()
	handle_input()
	update_animation()
	update_facing()
	#print(animated_sprite.animation, animation_locked, falling)


func handle_input():
	if hp <= 0:
		velocity = Vector2(0, 0)
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.play("jump_start")
		animation_locked = true
		$Jump.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("move_left", "move_right", "buffer", "buffer")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if Input.is_action_just_pressed("attack") and off_cooldown:
		shoot()
		off_cooldown = false
		$AttackCooldown.start()


func update_animation():
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	
	if velocity.y > 0 and not falling:
		animated_sprite.play("jump_down")
		animation_locked = true
		falling = true
	
	if invincible:
		if visible:
			visible = false
		else:
			visible = true
	elif hp > 0:
		visible = true


func update_facing():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true


func _on_animated_sprite_2d_animation_finished():
	if(animated_sprite.animation == "jump_end" or 
	animated_sprite.animation == "attack_ground" or
	animated_sprite.animation == "hit"):
		animation_locked = false
	elif (animated_sprite.animation == "attack_air_up"):
		animated_sprite.play("jump_up")
	elif (animated_sprite.animation == "attack_air_down"):
		animated_sprite.play("jump_down")
	elif (animated_sprite.animation == "death"):
		visible = false
		death.emit()


func shoot():
	if is_on_floor():
		animation_locked = true
		animated_sprite.play("attack_ground")
	elif not falling:
		animated_sprite.play("attack_air_up")
	else:
		animated_sprite.play("attack_air_down")
	$Shoot.play()
	
	
	var fireball = fireball_path.instantiate()
	
	get_parent().add_child(fireball)
	
	if not animated_sprite.flip_h:
		fireball.direction = 1
	else:
		fireball.direction = -1
	
	var fireball_start := Vector2(fireball.direction * 40, 8)
	
	fireball.position = position + fireball_start


func _on_attack_cooldown_timeout():
	off_cooldown = true


func _on_enemy_collision_body_entered(_body):
	if not invincible:
		hp -= 1
		animation_locked = true
		hit.emit()
		
		if (hp <= 0):
			animated_sprite.play("death")
			invincible = true
			$Death.play()
		
		else:
			animated_sprite.play("hit")
			invincible = true
			$InvincibilityFrames.start()
			$Hit.play()


func _on_invincibility_frames_timeout():
	invincible = false
