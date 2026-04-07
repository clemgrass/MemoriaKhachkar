extends Node3D


func _on_all_solved():
	$"..".visible = false
	self.disabled = true
