extends Node3D

@onready var pause_menu = $UI/PauseMenu
@onready var resume_button = $UI/Button
@onready var key_bindings = $UI/KeyBindingsPM

@onready var key_bindings_tutorial = $UI/KeyBindings
@onready var mov = $UI/KeyBindings/mov
@onready var akey = $UI/KeyBindings/AKeyLight
@onready var dKey = $UI/KeyBindings/DKeyLight
@onready var sKey = $UI/KeyBindings/SKeyLight
@onready var wKey = $UI/KeyBindings/WKeyLight
@onready var album = $UI/KeyBindings/album
@onready var eKey = $UI/KeyBindings/EKeyLight
@onready var camera = $UI/KeyBindings/camera
@onready var qKey = $UI/KeyBindings/QKeyLight
@onready var sprint = $UI/KeyBindings/sprint
@onready var shiftKey = $UI/KeyBindings/ShiftKeyLight
@onready var jump = $UI/KeyBindings/jump
@onready var spaceKey = $UI/KeyBindings/SpaceKeyLight
@onready var interact = $UI/KeyBindings/interact
@onready var mouseLeft = $UI/KeyBindings/MouseLeftKeyLight
@onready var zoomIn = $UI/KeyBindings/zoomIn
@onready var zoomOut = $UI/KeyBindings/zoomOut
@onready var mouseLeft2 = $UI/KeyBindings/MouseLeftKeyLight2
@onready var mouseRight = $UI/KeyBindings/MouseRightKeyLight

@onready var tutorialDone = false
@onready var in_camera = false
@onready var in_album = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	var puzzle = get_tree().get_first_node_in_group("puzzle0")
	var doors = get_tree().get_nodes_in_group("door")
	
	var khachkars = get_tree().get_nodes_in_group("khachkars")
	var room_khachkars = get_tree().get_first_node_in_group("room_khachkars")
	var album = get_tree().get_first_node_in_group("album")
	
	var final_door = get_tree().get_first_node_in_group("final_door")
	
	var player = get_tree().get_first_node_in_group("player")
	
	for door in doors:
		puzzle.puzzle0_solved.connect(door._on_puzzle_solved)
		
	for khachkar in khachkars:
		khachkar.puzzle_solved.connect(room_khachkars._on_puzzle_solved)
		khachkar.puzzle_solved.connect(album._on_puzzle_solved)
	
	room_khachkars.all_solved.connect(final_door._on_all_solved)

	puzzle.puzzle0_solved.connect(album._on_puzzle_solved)
	puzzle.puzzle0_solved.connect(player._on_puzzle_solved)
	

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		key_bindings.visible = true
		resume_button.visible = true
		toggle_pause()
	if not tutorialDone:
		tutorial_bindings_check(event)

func tutorial_bindings_check(event):
	if Input.is_key_pressed(KEY_W) and not in_album and not in_camera:
		wKey.visible = false
		tutorial_check()
	if Input.is_key_pressed(KEY_A) and not in_album and not in_camera:
		akey.visible = false
		tutorial_check()
	if Input.is_key_pressed(KEY_S) and not in_album and not in_camera:
		sKey.visible = false
		tutorial_check()
	if Input.is_key_pressed(KEY_D) and not in_album and not in_camera:
		dKey.visible = false
		tutorial_check()
	if event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.echo and not in_camera:
			eKey.visible = false
			in_album = not in_album
			tutorial_check()
	if event is InputEventKey:
		if event.keycode == KEY_Q and event.pressed and not event.echo and not in_album:
			qKey.visible = false
			in_camera =  not in_camera
			tutorial_check()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and in_camera:
		mouseLeft2.visible = false
		tutorial_check()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and in_camera:
		mouseRight.visible = false
		tutorial_check()
	if Input.is_key_pressed(KEY_SHIFT) and not in_album and not in_camera:
		shiftKey.visible = false
		tutorial_check()
	if Input.is_key_pressed(KEY_SPACE) and not in_album and not in_camera:
		spaceKey.visible = false
		tutorial_check()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not in_album and not in_camera:
		mouseLeft.visible = false
		tutorial_check()
		

func tutorial_check():
	if not akey.visible and not dKey.visible and not sKey.visible and not wKey.visible:
		mov.visible = false
	if not eKey.visible:
		album.visible = false
	if not qKey.visible:
		camera.visible = false
	if not shiftKey.visible:
		sprint.visible = false
	if not spaceKey.visible:
		jump.visible = false
	if not mouseLeft2.visible:
		zoomIn.visible = false
	if not mouseRight.visible:
		zoomOut.visible = false
	if not mouseLeft.visible:
		interact.visible = false
	
	if not mov.visible and not album.visible and not camera.visible and not sprint.visible and not jump.visible and not interact.visible and not zoomIn.visible and not zoomOut.visible:
		key_bindings_tutorial.visible = false
		tutorialDone = true


func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused


func _on_button_pressed() -> void:
	key_bindings.visible = false
	pause_menu.visible = false
	resume_button.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
