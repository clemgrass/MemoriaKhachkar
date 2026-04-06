extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	var puzzle = get_tree().get_first_node_in_group("puzzle0")
	var door = get_tree().get_first_node_in_group("door")
	
	var khachkars = get_tree().get_nodes_in_group("khachkars")
	var room_khachkars = get_tree().get_first_node_in_group("room_khachkars")
	var album = get_tree().get_first_node_in_group("album")
	
	var final_door = get_tree().get_first_node_in_group("final_door")

	for khachkar in khachkars:
		khachkar.puzzle_solved.connect(room_khachkars._on_puzzle_solved)
		khachkar.puzzle_solved.connect(album._on_puzzle_solved)
	
	room_khachkars.all_solved.connect(final_door._on_all_solved)
	
	puzzle.puzzle0_solved.connect(door._on_puzzle_solved)
	puzzle.puzzle0_solved.connect(album._on_puzzle_solved)
