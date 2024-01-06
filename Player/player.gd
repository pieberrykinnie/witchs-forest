extends CharacterBody2D


const fireball_path = preload("res://fireball.tscn")
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const COOLDOWN = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var toward = 1 #1 is right, -1 is left
var time = 0
var hp = 8
var collision

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			toward = 1
		if direction < 0:
			toward = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("ui_accept") and time >= COOLDOWN:
		shoot()
		time = 0
	time += delta
		
	move_and_slide()
	
func shoot():
	var fireball = fireball_path.instantiate()
	
	get_parent().add_child(fireball)
	fireball.position = position + Vector2(1, 0)*toward
	fireball.toward = toward


func _on_area_2d_body_entered(body):
	hp -= 1
	#print(hp)
	if hp == 0:
		hp = 8
		get_tree().reload_current_scene()



func _on_enemy_detection_body_entered(body):
	hp -= 1
	#body.destroy()
	if hp == 0:
		hp = 8
		get_tree().reload_current_scene()
	velocity.y = JUMP_VELOCITY
	velocity.x = -toward*SPEED	
	move_and_slide()
