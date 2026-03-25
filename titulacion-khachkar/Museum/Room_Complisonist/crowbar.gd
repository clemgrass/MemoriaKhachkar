extends Node3D


# Called when the node enters the scene tree for the first time.
func grab_crowbar():
	$"..".visible = false
	self.use_collision = false
	
