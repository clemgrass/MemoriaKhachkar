extends Button

@onready var hover_scale = Vector2(1.2, 1.2)  
@onready var normal_scale = Vector2(1, 1)     
@onready var scene_path = "res://World/MainGame.tscn"
	
func _on_mouse_entered() -> void:
	create_tween().tween_property(self, "scale", hover_scale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	create_tween().tween_property(self, "scale", normal_scale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
