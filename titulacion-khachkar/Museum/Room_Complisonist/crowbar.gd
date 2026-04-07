extends Node3D


# Called when the node enters the scene tree for the first time.
func grab_crowbar():
	$"..".visible = false
	$coll_crow.disabled = true
	
