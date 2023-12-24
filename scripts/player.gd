extends CharacterBody2D


@export var speed := 200.0
@export var jump_velocity := -400.0

@onready var animated_sprite := $AnimatedSprite2D

const fireball_path = preload("res://scenes/fireball.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked := false
var falling := false
var direction := Vector2.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	else:
		if falling:
			animated_sprite.play("jump_end")
			falling = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.play("jump_start")
		animation_locked = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("move_left", "move_right", "buffer", "buffer")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if Input.is_action_just_pressed("attack"):
		shoot()

	move_and_slide()
	update_animation()
	update_facing()
	#print(animated_sprite.animation, animation_locked, falling)


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


func update_facing():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true


func _on_animated_sprite_2d_animation_finished():
	if(animated_sprite.animation == "jump_end"):
		animation_locked = false


func shoot():
	var fireball = fireball_path.instantiate()
	
	get_parent().add_child(fireball)
	
	fireball.position = position
	
	if not animated_sprite.flip_h:
		fireball.direction = 1
	else:
		fireball.direction = -1
