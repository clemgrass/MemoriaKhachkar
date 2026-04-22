extends Area3D


func _on_body_entered(body):
	if body.name == "piece1":
		if $"..".placeable(body):
			body.queue_free()
			$"../k1Static".visible = true
			$"..".change_place(0)
	if body.name == "piece2":
		if $"..".placeable(body):
			body.queue_free()
			$"../k2Static".visible = true
			$"..".change_place(1)
	if body.name == "piece3":
		if $"..".placeable(body):
			body.queue_free()
			$"../k3Static".visible = true
			$"..".change_place(2)
	if body.name == "piece4":
		if $"..".placeable(body):
			body.queue_free()
			$"../k4Static".visible = true
			$"..".change_place(3)
	if body.name == "piece5":
		if $"..".placeable(body):
			body.queue_free()
			$"../k5Static".visible = true
			$"..".change_place(4)
	if body.name == "piece6":
		if $"..".placeable(body):
			body.queue_free()
			$"../k6Static".visible = true
			$"..".change_place(5)
