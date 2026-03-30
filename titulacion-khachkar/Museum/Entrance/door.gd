extends Node3D


var opened = false

func _on_puzzle_solved():
	if opened:
		return
	opened = true
	$AnimationPlayer.play("open")
