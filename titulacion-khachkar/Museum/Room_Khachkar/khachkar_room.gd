extends Node3D

signal all_solved

var puzzles_solved: Array = [false, false, false, false, false, false]


# Called when the node enters the scene tree for the first time.
func _on_puzzle_solved(khachkar: int):
	if khachkar == 1:
		$lightK1/khachkar1.visible = true
		puzzles_solved[0] = true
	if khachkar == 2:
		$lightK2/Khachkar2.visible = true
		puzzles_solved[1] = true
	if khachkar == 3:
		$lightK3/Khachkar3.visible = true
		puzzles_solved[2] = true
	if khachkar == 4:
		$lightK4/Khachkar4.visible = true
		puzzles_solved[3] = true
	if khachkar == 5:
		$lightK5/Khachkar5.visible = true
		puzzles_solved[4] = true
	if khachkar == 6:
		$lightK6/Kachkar6.visible = true
		puzzles_solved[5] = true
	open_final_room()

func open_final_room():
	for solved in puzzles_solved:
		if not solved:
			return
	emit_signal("all_solved")
