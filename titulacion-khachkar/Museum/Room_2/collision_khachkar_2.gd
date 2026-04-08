extends Node3D

signal puzzle_solved

func khachkar_photo(allowed: bool):
	#Photo for the album 
	#Particle effect of khachkar dissapearing
	#Appears in khachkar room
	
	#disappears khachkar
	$"..".visible = false
	$khachkarColl.disabled = true
	
	emit_signal("puzzle_solved", 2)
