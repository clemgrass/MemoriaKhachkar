extends Area3D


func _on_body_entered(body):
	if body.name == "piece1":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k1Static".visible = true
			$"..".change_place(0)
	if body.name == "piece2":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k2Static".visible = true
			$"..".change_place(1)
	if body.name == "piece3":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k3Static".visible = true
			$"..".change_place(2)
	if body.name == "piece4":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k4Static".visible = true
			$"..".change_place(3)
	if body.name == "piece5":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k5Static".visible = true
			$"..".change_place(4)
	if body.name == "piece6":
		if $"..".placeable(body):
			body.visible = false
			body.freeze = true
			$"../k6Static".visible = true
			$"..".change_place(5)
