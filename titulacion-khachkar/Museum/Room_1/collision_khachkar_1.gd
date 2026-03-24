extends CSGBox3D


func khachkar_photo():
	#Photo for the album 
	#Particle effect of khachkar dissapearing
	#Appears in khachkar room
	
	#disappears khachkar
	$"..".visible = false
	self.use_collision = false
