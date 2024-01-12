extends Node2D

#general variables of the world map
var horizontal_map_border = [-140, 2390]


#if we want to have more bats, we have to call each nodes (could use for loop to do so)
#Bat variables
var bat_in_tree = [true, true, true]
var bats = [$Bat, $Bat2, $Bat3]

#Boss model variables
var boss_wait_time = 1
var boss_action_moment = 0
var boss_random_ability 
var boss_die = false
var boss_is_special_move = 0 #0 is not, 1 is true


func _process(delta):
	#Setting boss border
	#$"Boss 1".special_charge_border = horizontal_map_border
	if not boss_die:
	#print(boss_die)
		$"Boss 1".player_position = $Player.position
		
		if $"Boss 1".die:
			$"Boss 1".destroy()
			boss_die = true
	####Bat attacking####
	
	
	var bats = [$Bat, $Bat2, $Bat3]
	for i in range(len(bat_in_tree)):
		#print(bats[i])
		if bat_in_tree[i]:
			if bats[i].detect_player:
				bats[i].attack($Player.position)
	
			if bats[i].die:
				bat_in_tree[i] = false
				bats[i].destroy()
	
	
	####Boss Decision Model####
	if not boss_die:
	#print("boss running")
		boss_action_moment += delta
		if boss_action_moment >= boss_wait_time:
			boss_decision_model(delta)
			boss_action_moment = 0
	
	
	
	
#Switching to boss scene (haven't done anything yet)	
func _on_gate_boss_body_entered(body):
	#get_tree().change_scene_to_file("res://Boss_scene.tscn")
	pass



###########################################################
			####BOSS DECISION MODEL 1####
##=====> BLINDLY RANDOM ABILITY
##########################################################

func boss_decision_model(delta):
	var rng = RandomNumberGenerator.new()
	
	boss_is_special_move = rng.randi_range(0, 1)
	
	if boss_is_special_move == 0:
		var boss_move = rng.randi_range(0, 2)
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
	
