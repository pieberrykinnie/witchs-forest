extends Node2D

@onready var boss_load = preload("res://scenes/boss_1.tscn")

var horizontal_map_border = [3617, 4027]
var boss_spawned := false
#Boss model variables
var boss_wait_time = 1
var boss_action_moment = 0
var boss_random_ability 
var boss_die = false
var boss_is_special_move = 0 #0 is not, 1 is true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Music by <a href="https://pixabay.com/users/not-kawaii-40269569/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=173852">not-kawaii</a> from <a href="https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=173852">Pixabay</a>
	$Music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if boss_spawned:
		#Setting boss border
		#$"Boss 1".special_charge_border = horizontal_map_border
		if not boss_die:
		#print(boss_die)
			$"Boss 1".player_position = $Player.position
			
			if $"Boss 1".die:
				$"Boss 1".destroy()
				boss_die = true
		
		####Boss Decision Model####
		if not boss_die:
		#print("boss running")
			boss_action_moment += delta
			if boss_action_moment >= boss_wait_time:
				boss_decision_model(delta)
				boss_action_moment = 0


func _on_player_death():
	$Restart.start()
	$Music.stop()
	$BossMusic.stop()


func _on_restart_timeout():
	get_tree().reload_current_scene()


func _on_spawn_boss_body_entered(body):
	if not boss_spawned:
		var boss = boss_load.instantiate()
		add_child(boss)
		boss.position = Vector2(3975, 950)
		boss_spawned = true
		# Music by alper omer esin from Pixabay
		$Music.stop()
		$BossMusic.play()
		
		

###########################################################
			####BOSS DECISION MODEL 1####
##=====> BLINDLY RANDOM ABILITY
##########################################################

func boss_decision_model(delta):
	var rng = RandomNumberGenerator.new()
	var boss_move
	boss_is_special_move = rng.randi_range(0, 1)
	
	if boss_is_special_move == 0:
		if boss_random_ability == 0:
			if $Player.position.x - $"Boss 1".position.x < 0:
				boss_move = 1
			if $Player.position.x - $"Boss 1".position.x > 0:
				boss_move = 0
		else:
			boss_move = rng.randi_range(0, 2)
		
		$"Boss 1".decision = $"Boss 1".MOVING_ABILITY[boss_move]
	
	if not $"Boss 1".special_move_sleep:
		if boss_is_special_move == 1 and not $"Boss 1".is_special_move_running:
			boss_random_ability  = rng.randi_range(0, len($"Boss 1".ABILITY) - 1)
			$"Boss 1".decision = $"Boss 1".ABILITY[boss_random_ability]
			$"Boss 1".special_move_sleep = true
			#print(1)
		#print($"Boss 1".is_special_move_running)
	else: 
		$"Boss 1".special_move_timer += delta
		#print($"Boss 1".special_move_timer)
		if $"Boss 1".special_move_timer >= $"Boss 1".SPECIAL_MOVE_COOLDOWN:
			$"Boss 1".special_move_sleep = false
			$"Boss 1".special_move_timer = 0


func _on_music_finished():
	$Music.play()
