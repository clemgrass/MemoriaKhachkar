extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	var puzzle = get_tree().get_first_node_in_group("puzzle0")
	var door = get_tree().get_first_node_in_group("door")
	
	var khachkars = get_tree().get_nodes_in_group("khachkars")
	var room_khachkars = get_tree().get_first_node_in_group("room_khachkars")

	for khachkar in khachkars:
		khachkar.puzzle_solved.connect(room_khachkars._on_puzzle_solved)
	
	if puzzle and door:
		puzzle.puzzle0_solved.connect(door._on_puzzle_solved)
		print("Connected puzzle to door")
	else:
		print("Connection failed:", puzzle, door)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
