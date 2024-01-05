extends StaticBody2D

#Boss model variables
var boss_wait_time = 1
var boss_action_moment = 0
var boss_random_ability 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	####Boss Decision Model####
	boss_action_moment += delta
	if boss_action_moment >= boss_wait_time:
		boss_decision_model(delta)
		boss_action_moment = 0


func boss_decision_model(delta):
	var rng = RandomNumberGenerator.new()
	boss_random_ability  = rng.randi_range(0, 6)
	
	$"Boss 1".decision = $"Boss 1".ABILITY[boss_random_ability]
