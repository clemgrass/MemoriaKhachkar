extends Node3D


func grand_final():
	$"../Camera3D".current = true
	$AnimationPlayer.play("camera_ending")
	await $AnimationPlayer.animation_finished
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect, "modulate:a", 1.0, 2.0)
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://MainMenu/mainMenu.tscn")
