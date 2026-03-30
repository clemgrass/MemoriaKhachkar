extends Node3D


# Called when the node enters the scene tree for the first time.
func _on_puzzle_solved(khachkar: int):
	if khachkar == 1:
		$lightK1/khachkar1.visible = true
	if khachkar == 2:
		$lightK2/Khachkar2.visible = true
	if khachkar == 3:
		$lightK3/Khachkar3.visible = true
	if khachkar == 4:
		$lightK4/Khachkar4.visible = true
	if khachkar == 5:
		$lightK5/Khachkar5.visible = true
	if khachkar == 6:
		$lightK6/Kachkar6.visible = true
	
