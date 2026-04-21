extends Node3D

@onready var pause_menu = $UI/PauseMenu

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
	
	await get_tree().create_timer(16.0).timeout
	$UI/KeyBindings.visible = false
	

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$UI/KeyBindings.visible = true
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused


func _on_button_pressed() -> void:
	$UI/KeyBindings.visible = false
	$UI/PauseMenu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
