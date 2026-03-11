extends Node3D


var opened = false

func open_door():
	if opened:
		return
	opened = true
	$AnimationPlayer.play("open")
