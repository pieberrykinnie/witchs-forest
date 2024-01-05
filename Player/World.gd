extends Node2D

#if we want to have more bats, we have to call each nodes (could use for loop to do so)
var bat_in_tree = [true, true, true]
var bats = [$Bat, $Bat2, $Bat3]

func _process(delta):
	var bats = [$Bat, $Bat2, $Bat3]
	for i in range(len(bat_in_tree)):
		if bat_in_tree[i]:
			if bats[i].detect_player:
				bats[i].attack($Player.position)
	
		if bats[i].die:
			bat_in_tree[i] = false
			bats[i].destroy()


func _on_gate_boss_body_entered(body):
	#get_tree().change_scene_to_file("res://Boss_scene.tscn")
	pass
