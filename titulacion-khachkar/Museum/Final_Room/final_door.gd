extends CSGBox3D


func _on_all_solved():
	self.visible = false
	self.use_collision = false
