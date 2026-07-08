extends Control

var background: ColorRect
var credits_text: RichTextLabel
var credits_tween: Tween

const FONT_SIZE := 64
const BOLD_FONT_SIZE := 86
const CREDITS_DURATION := 45.0

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
	build_credits()
	play_credits()


func build_credits():
	var screen_size := get_viewport_rect().size

	position = Vector2.ZERO
	size = screen_size
	z_index = 100

	background = ColorRect.new()
	background.color = Color.BLACK
	background.position = Vector2.ZERO
	background.size = screen_size
	add_child(background)

	credits_text = RichTextLabel.new()
	credits_text.bbcode_enabled = true
	credits_text.fit_content = true
	credits_text.scroll_active = false
	credits_text.text = CREDITS_BBCODE

	credits_text.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	credits_text.add_theme_font_size_override("bold_font_size", BOLD_FONT_SIZE)

	credits_text.position = Vector2(0, screen_size.y)
	credits_text.size = Vector2(screen_size.x, 5000)
	credits_text.custom_minimum_size = Vector2(screen_size.x, 5000)

	add_child(credits_text)


func play_credits():
	if credits_tween:
		credits_tween.kill()

	await get_tree().process_frame
	await get_tree().process_frame

	var screen_size := get_viewport_rect().size
	var end_y := -credits_text.get_content_height() - 100.0

	credits_tween = create_tween()
	credits_tween.tween_property(
		credits_text,
		"position:y",
		end_y,
		CREDITS_DURATION
	)

	await credits_tween.finished

	queue_free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
