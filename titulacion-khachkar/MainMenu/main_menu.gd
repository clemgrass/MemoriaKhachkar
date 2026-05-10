# ============================================================================
# VERSIÓN ALTERNATIVA: CON ANIMACIÓN DE LOADING MÁS BONITA
# ============================================================================

extends Control
const GAME_SCENE := "res://World/MainGame.tscn"

@onready var progress_bar = $ProgressBar
@onready var play_button = $Node2D/Play
@onready var quit_button = $Node2D/Quit
@onready var loading_label = $LoadingLabel  # Label que dice "Cargando..."

var packed_scene: PackedScene
var game_instance: Node
var is_loaded := false
var is_transitioning := false

var loading_dots := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	ResourceLoader.load_threaded_request(GAME_SCENE)
	progress_bar.value = 0
	progress_bar.max_value = 100
	
	# Animar los puntos de "Cargando..."
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_loading_timer_timeout)
	add_child(timer)
	timer.start()

func _on_loading_timer_timeout() -> void:
	loading_dots = (loading_dots + 1) % 4
	var dots = ".".repeat(loading_dots)
	loading_label.text = "Cargando%s" % dots

func _process(delta: float) -> void:
	if is_loaded or is_transitioning:
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
			_on_scene_loaded_success()
		
		ResourceLoader.THREAD_LOAD_FAILED:
			_on_scene_loaded_failed()

func _on_scene_loaded_success() -> void:
	is_loaded = true
	packed_scene = ResourceLoader.load_threaded_get(GAME_SCENE)
	game_instance = packed_scene.instantiate()
	progress_bar.visible = false
	loading_label.visible = false
	play_button.disabled = false

func _on_play_pressed() -> void:
	if not is_loaded or is_transitioning:
		return
	
	is_transitioning = true
	play_button.disabled = true
	quit_button.disabled = true
	
	await fade_out()
	change_to_game_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func fade_out() -> void:
	var layer = CanvasLayer.new()
	layer.layer = 100
	
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	overlay.size = get_viewport().get_visible_rect().size
	
	layer.add_child(overlay)
	add_child(layer)
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.3)
	
	await tween.finished

func change_to_game_scene() -> void:
	get_tree().root.add_child(game_instance)
	get_tree().current_scene = game_instance
	queue_free()

func _on_scene_loaded_failed() -> void:
	print("Error cargando escena")
	await get_tree().create_timer(2.0).timeout
	ResourceLoader.load_threaded_request(GAME_SCENE)
