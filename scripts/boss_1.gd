extends CharacterBody2D

#Loading file
const fireball_path = preload("res://scenes/enemy_bullet.tscn")
const summon_ball_path = preload("res://scenes/summon_ball.tscn")
const summon_slime_path = preload("res://scenes/slime.tscn")
const summon_bat_path = preload("res://scenes/bat.tscn")

#general constants 
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const ABILITY = ["jump_and_hit", "charge_and_hit", "fireball", "summon_monster"]
const MOVING_ABILITY = ["left", "right", "up"]
const SPECIAL_MOVE_COOLDOWN = 0.2 #cannot use any special move until 3 seconds after using the previous skill

#General variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var toward = 1 #1 is the boss moving to the right, -1 is the boss moving to the left
var decision #what the boss will do
var hp = 32
var Iframe = 0
var die = false
var collision

#Player Variables
var player_position

##SPECIAL MOVE VARIABLES
var is_special_move_running = false
var special_move_sleep = false #Can you cast special move or not
var special_move_timer = 0

#Special jump variables
var special_jump = false
var special_jump_timer = 0

#Special charge and hit variables
var special_charge = false
var special_charge_timer = 0 #Counting how long special charge is running
var special_charge_anglex = 1 #Value of cos(angle) that angle is the angle of the line from the boss to the player and the horizontal line
var special_charge_angley = 0 #Value of sin(angle) that angle is the angle of the line from the boss to the player and the horizontal line
var special_charge_border =  [3517, 4127] #restriction of the special charge --> if the boss hit the left wall, or right wall of the scence, the special move will stop
var special_charge_acceleration = 200 #the change of the speed of boss while using special charge and hit

#Special fireball
var special_fireball = false
var special_fireball_timer = 0
var special_fireball_moment = 0
var special_fireball_moment_delta = 0.5

#Special summon
var special_summon = false
var special_summon_ball
var special_summon_monster_num = 2 #number of monsters boss can summon
var special_summon_monster_type
var special_summon_bat_list = []

#-----------------------------------------------------------------------------
func _ready():
	$AnimatedSprite2D.play("enter")


func _physics_process(delta):
	####UPDATING GENERAL VARIABLE####
	if Iframe > 0:
		Iframe -= delta
	
	####GAME PROCESSING####
	if not special_charge:
		# Add the gravity.
		if not is_on_floor() and not special_jump:
			velocity.y += gravity * delta

		# Handle jump.
		if decision == "up" and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction 
		
		# Get direction --> 1 moving left, -1 moving right
		if decision == "left":
			direction = 1
		elif decision == "right":
			direction = -1
		
		#Moving horizontally
		if direction:
			velocity.x = direction * SPEED
			if direction > 0:
				toward = 1
			else: toward = -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)


		#Handle special skills
		if decision == "jump_and_hit":
			is_special_move_running = true
			special_jump = true
			jump_and_hit(position, false)
			decision = ""
			
		if decision == "charge_and_hit":
			is_special_move_running = true
			special_charge = true
			decision = ""
			
		if decision == "fireball":
			is_special_move_running = true
			special_fireball = true
			decision = ""
			
		if decision == "summon_monster":
			is_special_move_running = true
			special_summon = true
			special_summon_ball = summon_ball_path.instantiate()
			summon_circle(special_summon_ball)
			decision = ""
		
		move_and_slide()
	

	
	#Special Jump
	if special_jump:
		special_jump_timer += delta
	
	if special_jump_timer >= 3:
		jump_and_hit(position, true)
		is_special_move_running = false

	#Special charge
	if special_charge:
		special_charge_timer += delta
		var temp_special_charge_speed = SPEED + (special_charge_timer/delta)*special_charge_acceleration
		charge_and_hit(position, toward, special_charge_border, delta, temp_special_charge_speed)
		
	if special_charge_timer >= 3:
		special_charge = false
		special_charge_timer = 0
		is_special_move_running = false


	#Special fireball
	if special_fireball:
		special_fireball_timer += delta
		
		if special_fireball_timer >= special_fireball_moment: 
			fireball(Vector2(100, 0))
			fireball(Vector2(100, -30))
			special_fireball_moment += special_fireball_moment_delta
			
	if special_fireball_timer >= 3:
		special_fireball = false
		special_fireball_timer = 0
		special_fireball_moment = 0
		is_special_move_running = false
		
	#Special summon
	if special_summon:
		if special_summon_ball.collision:
			summon_monster(special_summon_ball.position)
			special_summon = false
			special_summon_ball.destroy()
			is_special_move_running = false
	
	for bat in special_summon_bat_list:
		if bat[0]:
			bat[1].attack(player_position)
			if bat[1].hp <= 0:
				bat[0] = false
				
				
	###Checking for bat that's dead and remove it from the list###
	var index = 0
	while index < len(special_summon_bat_list):
		if special_summon_bat_list[index][0]:
			index += 1
		else:
			special_summon_bat_list[index][1].destroy()
			for i in range(index, len(special_summon_bat_list) - 1):
				special_summon_bat_list[i] = special_summon_bat_list[i + 1]
			special_summon_bat_list.remove_at(len(special_summon_bat_list) - 1)
#----------------------------------------------------------

####SPECIAL SKILLS####

#Special Jump and hit the ground
func jump_and_hit(pos, hit):
	
	#Jump to the sky
	while position.y > 900:
		position.y -= gravity*0.016
		velocity.y = 0
		
	#hit the ground after 5 seconds
	if hit:
		velocity.y = -4*JUMP_VELOCITY
		special_jump = false
		special_jump_timer = 0
	


#Special charge and hit
func charge_and_hit(pos, angle, border, delta, speed):
	if position.x >= border[0] and position.x <= border[1]:
		position.x += toward*speed*delta



#Special fireball
func fireball(delta_fire_pos):
	var fire = fireball_path.instantiate()
	
	get_parent().add_child(fire)
	fire.position = position + Vector2(delta_fire_pos.x*toward, delta_fire_pos.y)
	fire.toward = toward



#Special summon
func summon_circle(summon_ball):
	get_parent().add_child(summon_ball)
	summon_ball.position = position + Vector2(100, 0)*toward
	summon_ball.toward = toward

func summon_monster(pos):
	var rng = RandomNumberGenerator.new()
	var monster 
	
	special_summon_monster_type = rng.randi_range(1, special_summon_monster_num)
	
	match special_summon_monster_type: 
		1:
			monster = summon_slime_path.instantiate()
			monster.toward = toward
		2: 
			monster = summon_bat_path.instantiate()
			monster.detect_player = true
			special_summon_bat_list.append([true, monster])
			
	get_parent().add_child(monster)
	monster.position = pos
	print(pos)
	#print(monster_type)




func _on_bullet_detection_body_entered(body):
	body.collision = true
	
	if Iframe <= 0:
		hp -= 1
		Iframe = 1
	
	if hp <= 0:
		die = true

func destroy():
	queue_free()
