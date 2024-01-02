extends Node2D

#if we want to have more bats, we have to call each nodes (could use for loop to do so)
var bat_in_tree = true

func _process(delta):
	if bat_in_tree:
		if $Bat.detect_player:
			$Bat.attack($Player.position)
	
		if $Bat.die:
			bat_in_tree = false
			$Bat.destroy()
	
