extends Node3D

var correct_notes: Array = ["do", "si", "mi", "si", "mi", "mi", "mi", "la", "sol", "mi", "sol", "la", "la", "sol", "mi", "sol", "la", "la", "re", "la"]
var glows: Array 
var pos_correct: int = 0


func _ready() -> void:
	glows = [$puzzle4/glow1, $puzzle4/glow2, $puzzle4/glow3, $puzzle4/glow4, $puzzle4/glow5, $puzzle4/glow6, $puzzle4/glow7, $puzzle4/glow8, $puzzle4/glow9, $puzzle4/glow10, $puzzle4/glow11, $puzzle4/glow12, $puzzle4/glow13, $puzzle4/glow14, $puzzle4/glow15, $puzzle4/glow16, $puzzle4/glow17, $puzzle4/glow18, $puzzle4/glow19, $puzzle4/glow20]

func note_played(note: String):
	if pos_correct >= glows.size():
		return
	
	var glow_mat = glows[pos_correct].material
	var alpha = glow_mat.albedo_color.a
	if note == correct_notes[pos_correct]:
		glows[pos_correct]
		glow_mat.albedo_color = Color(0, 1, 0, alpha)
		pos_correct += 1
	else:
		glow_mat.albedo_color = Color(1, 0, 0, alpha)
		await get_tree().create_timer(2.0).timeout
		for glow in glows:
			var mat = glow.material
			mat.albedo_color = Color(1, 1, 1, alpha)

		pos_correct = 0
	
	if pos_correct == correct_notes.size():
		$windowsProtect/KhachkarWinProtect5.visible = false
		$AnimationPlayer.play("windows_down")
		await $AnimationPlayer.animation_finished
		$Khachkar4/collisionKhachkar4/khachkarColl.disabled = false
		
