extends CSGBox3D



func pressed_button():
	var area = $"../../areaVisual"
	
	for body in area.get_overlapping_bodies():
		if body.name == "PlayerController":
			$"../khachkar2".visible = false
			$"../../Khachkar2".visible = true
			$"../../Khachkar2/collisionKhachkar".use_collision= true
			return
