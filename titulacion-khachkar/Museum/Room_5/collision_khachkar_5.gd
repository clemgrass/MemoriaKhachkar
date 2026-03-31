extends CSGBox3D

signal puzzle_solved

func khachkar_photo(allowed: bool):
	#Photo for the album 
	#Particle effect of khachkar dissapearing
	#Appears in khachkar room
	
	#disappears khachkar
	$"..".visible = false
	self.use_collision = false
	
	emit_signal("puzzle_solved", 5)
