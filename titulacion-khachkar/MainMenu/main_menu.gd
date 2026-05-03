extends Control

const GAME_SCENE := "res://World/MainGame.tscn"

@onready var progress_bar = $ProgressBar
var packed_scene
var is_loaded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			is_loaded = true

func _on_play_pressed() -> void:
	if !is_loaded:
		return
		
	$Node2D/Play.disabled = true
	$Node2D/Quit.disabled = true
	$AnimationPlayer.play("start_game")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(packed_scene)
