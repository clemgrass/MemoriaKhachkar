extends Node2D

const MAIN_MENU_SCENE := "res://MainMenu/mainMenu.tscn"

const FONT_SIZE := 72
const BOLD_FONT_SIZE := 96
const CREDITS_DURATION := 45.0

var camera: Camera2D
var background: ColorRect
var credits_text: RichTextLabel
var credits_tween: Tween

const CREDITS_BBCODE := """
[center][b]CRÉDITOS[/b]

[b]Creador[/b]
Clemente Grass

[b]Música[/b]
Nicolás Marín

[b]Testers[/b]
Mateo Grass
Martín Vergara

[b]Agradecimientos especiales[/b]
A los jugadores que realizaron el cuestionario:

Joaquín Uribe
Nicolás David Marín Videla
Catalina Belén Alarcón Pino
Santiago Maldonado Rottmann
Cristóbal Heimrich Morales
Javier von Kretschmann Rojas
Guillermo von Kretschmann
Martin Retamal
Francisco García
Trinidad Beatriz Muñoz Pardo
Cristóbal Ignacio Berríos Lara
Vicente Barrios
Benjamin Alvano Rogers
Eduardo Teixidó
Franco Andrés Giannoni Humud
Cristobal Ugarte Muñoz
José Miguel Isaac Díaz
Roberto Rivera Carrasco
Bastian Caballero Silva
Alonso Rivera
Sergio Andrés Urzúa Donoso
Martín Jesús Corvalán Rogers
Ernesto Ayala
Manuela Cosio Cortés
Valentina Sotelo
Nicolás Duarte H.
Rodolfo Salgado
Agustín Eduardo González Hidalgo
Tania Andrea Hausdorf Sepúlveda[/center]
"""


func _ready():
	build_scene()
	play_credits()


func build_scene():
	var screen_size := get_viewport_rect().size

	camera = Camera2D.new()
	camera.position = screen_size / 2.0
	add_child(camera)
	camera.make_current()

	background = ColorRect.new()
	background.color = Color.BLACK
	background.position = Vector2(-2000, -2000)
	background.size = Vector2(6000, 10000)
	add_child(background)

	credits_text = RichTextLabel.new()
	credits_text.bbcode_enabled = true
	credits_text.fit_content = true
	credits_text.scroll_active = false
	credits_text.text = CREDITS_BBCODE

	credits_text.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	credits_text.add_theme_font_size_override("bold_font_size", BOLD_FONT_SIZE)

	credits_text.position = Vector2(0, screen_size.y + 100)
	credits_text.size = Vector2(screen_size.x, 6000)
	credits_text.custom_minimum_size = Vector2(screen_size.x, 6000)

	add_child(credits_text)


func play_credits():
	await get_tree().process_frame
	await get_tree().process_frame

	var content_height := credits_text.get_content_height()
	var screen_size := get_viewport_rect().size

	var start_y := screen_size.y / 2.0
	var end_y := screen_size.y + content_height + 300.0

	camera.position.y = start_y

	credits_tween = create_tween()
	credits_tween.tween_property(
		camera,
		"position:y",
		end_y,
		CREDITS_DURATION
	)

	await credits_tween.finished

	go_back_to_menu()


func go_back_to_menu():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		go_back_to_menu()
