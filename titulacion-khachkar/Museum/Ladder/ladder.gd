extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("enter_ladder"):
		body.enter_ladder(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.has_method("exit_ladder"):
		body.exit_ladder()
