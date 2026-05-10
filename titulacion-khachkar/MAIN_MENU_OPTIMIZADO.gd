extends Control
## MAIN MENU OPTIMIZADO
## - Carga asincrónica de la escena principal
## - Transiciones suaves con fade
## - Feedback visual completo
## - Sin freezes nunca

const GAME_SCENE := "res://World/MainGame.tscn"

@onready var progress_bar = $ProgressBar
@onready var play_button = $Node2D/Play
@onready var quit_button = $Node2D/Quit

var packed_scene: PackedScene
var game_instance: Node
var is_loaded := false
var is_transitioning := false  # Prevenir clicks múltiples

# Configurable
var show_loading_screen := true
var transition_duration := 0.3

func _ready() -> void:
	"""Inicializar el menú y empezar a cargar la escena de juego"""
	print("🎮 Main Menu - Iniciando carga de escena principal...")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Conectar botones
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Iniciar carga asincrónica
	ResourceLoader.load_threaded_request(GAME_SCENE)
	
	# Setup visual
	progress_bar.value = 0
	progress_bar.max_value = 100
	
	print("⏳ Cargando: %s" % GAME_SCENE)

func _process(delta: float) -> void:
	"""Monitorear progreso de carga"""
	if is_loaded or is_transitioning:
		return
	
	# Obtener progreso
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(
		GAME_SCENE,
		progress
	)
	
	# Actualizar progress bar
	if progress.size() > 0:
		progress_bar.value = progress[0] * 100
		print("📊 Carga: %.0f%%" % progress_bar.value)
	
	# Procesar estados
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_on_scene_loaded_success()
		
		ResourceLoader.THREAD_LOAD_FAILED:
			_on_scene_loaded_failed()
		
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Seguir esperando
			pass

func _on_scene_loaded_success() -> void:
	"""La escena se cargó exitosamente"""
	if is_loaded:
		return
	
	is_loaded = true
	
	print("✅ Escena cargada correctamente")
	
	# Obtener recurso
	packed_scene = ResourceLoader.load_threaded_get(GAME_SCENE)
	
	if packed_scene == null:
		print("❌ Error: packed_scene es null")
		return
	
	# Instanciar escena (no agregar a árbol aún)
	game_instance = packed_scene.instantiate()
	
	if game_instance == null:
		print("❌ Error: no se pudo instanciar la escena")
		return
	
	# Ocultar progress bar
	progress_bar.visible = false
	
	# Habilitar botón Play
	play_button.disabled = false
	print("🎮 Listo para jugar - presiona Play")

func _on_scene_loaded_failed() -> void:
	"""La escena falló al cargar"""
	print("❌ Error al cargar la escena: %s" % GAME_SCENE)
	progress_bar.visible = true
	progress_bar.value = 0
	
	# Mostrar error al usuario
	if has_node("ErrorLabel"):
		$ErrorLabel.text = "Error cargando escena"
		$ErrorLabel.visible = true
	
	# Reintentar carga
	print("🔄 Reintentando carga...")
	await get_tree().create_timer(2.0).timeout
	ResourceLoader.load_threaded_request(GAME_SCENE)

func _on_play_pressed() -> void:
	"""Usuario presionó Play"""
	if not is_loaded:
		print("⏳ Escena aún cargando, espera...")
		return
	
	if is_transitioning:
		print("🔄 Transición en progreso...")
		return
	
	is_transitioning = true
	
	print("🎬 Iniciando transición a juego...")
	
	# Desactivar botones
	play_button.disabled = true
	quit_button.disabled = true
	
	# Fade out suave
	await fade_out()
	
	# Cambiar a escena de juego
	change_to_game_scene()
	
	# Fade in suave (lo hace la nueva escena)
	await get_tree().create_timer(0.1).timeout

func _on_quit_pressed() -> void:
	"""Usuario presionó Quit"""
	print("👋 Saliendo del juego...")
	get_tree().quit()

func fade_out() -> void:
	"""Transición de fade out (negro)"""
	var overlay = create_fade_overlay()
	add_child(overlay)
	
	# Animar
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(overlay, "color:a", 1.0, transition_duration)
	
	await tween.finished

func change_to_game_scene() -> void:
	"""Cambiar a la escena de juego"""
	if game_instance == null:
		print("❌ game_instance es null")
		return
	
	# Agregar escena al árbol
	get_tree().root.add_child(game_instance)
	get_tree().current_scene = game_instance
	
	print("✅ Escena de juego activada")
	
	# Liberar menú
	queue_free()

func create_fade_overlay() -> ColorRect:
	"""Crear overlay para transición de fade"""
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.z_index = 9999
	return overlay

# ============================================================================
# MEJORAS ADICIONALES OPCIONALES
# ============================================================================

func _input(event: InputEvent) -> void:
	"""
	Permitir skip de loading screen con ESC (opcional)
	Remover esta función si no quieres que los usuarios puedan skipear
	"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if is_loaded and not is_transitioning:
				_on_play_pressed()

# ============================================================================
# VERSIÓN ALTERNATIVA: CON ANIMACIÓN DE LOADING MÁS BONITA
# ============================================================================

"""
VERSIÓN ALTERNATIVA: Si quieres una barra de carga más animada

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
	var dots = "." * loading_dots
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
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.z_index = 9999
	add_child(overlay)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
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
"""

# ============================================================================
# DEPURACIÓN
# ============================================================================

func print_debug_info() -> void:
	"""Información de depuración (ejecutar en consola si necesitas)"""
	print("\n=== DEBUG INFO ===")
	print("Escena: %s" % GAME_SCENE)
	print("Cargada: %s" % is_loaded)
	print("Transicionando: %s" % is_transitioning)
	print("Progress Bar: %.0f%%" % progress_bar.value)
	if packed_scene:
		print("PackedScene: OK")
	if game_instance:
		print("Game Instance: OK")
	print("=================\n")
