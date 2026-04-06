extends Node3D

var photok0: Sprite3D
var photok1: Sprite3D
var photok2: Sprite3D
var photok3: Sprite3D
var photok4: Sprite3D
var photok5: Sprite3D
var photok6: Sprite3D

func _ready() -> void:
	photok0 = $photok0
	photok1 = $photok1
	photok2 = $photok2
	photok3 = $photok3
	photok4 = $photok4
	photok5 = $photok5
	photok6 = $photok6


func _on_puzzle_solved(khachkar: int):
	match khachkar:
		0:
			photok0.visible = true
		1:
			photok1.visible = true
		2:
			photok2.visible = true
		3:
			photok3.visible = true
		4:
			photok4.visible = true
		5:
			photok5.visible = true
		6:
			photok6.visible = true
