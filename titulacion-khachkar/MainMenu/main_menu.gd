extends Control

const GAME_SCENE := "res://World/MainGame.tscn"

@onready var progress_bar = $ProgressBar
var packed_scene
var game_instance
var is_loaded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_loaded:
		return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(
		GAME_SCENE,
		progress
	)

	if progress.size() > 0:
		progress_bar.value = progress[0] * 100

	match status:

		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.visible = false
			packed_scene = ResourceLoader.load_threaded_get(GAME_SCENE)
			game_instance = packed_scene.instantiate()
			is_loaded = true

func _on_play_pressed() -> void:
	if !is_loaded:
		return
		
	$Node2D/Play.disabled = true
	$Node2D/Quit.disabled = true
	get_tree().root.add_child(game_instance)
	queue_free()
