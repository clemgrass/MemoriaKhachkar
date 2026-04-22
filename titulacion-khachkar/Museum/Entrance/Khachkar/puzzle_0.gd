extends Node3D

var pieces_placed: Array = [false, false, false, false, false, false]
signal puzzle0_solved

func puzzle_state():
	print(pieces_placed)
	for piece in pieces_placed:
		if not piece:
			return 
	print("Solved")
	$"../../fountainB/collFinal".disabled = false
	emit_signal("puzzle0_solved", 0)

func change_place(piece: int):
	pieces_placed[piece] = true
	puzzle_state()
	
func placeable(piece: RigidBody3D) -> bool:
	if piece.name == "piece1":
		if pieces_placed[1]:
			return true
		else:
			return false
	if piece.name == "piece3":
		if pieces_placed[3]:
			return true
		else:
			return false
	if piece.name == "piece5":
		if pieces_placed[5]:
			return true
		else:
			return false
	return true
		
