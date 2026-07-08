extends Control

@onready var black_background: ColorRect = $ColorRect
@onready var credits_scroll: ScrollContainer = $ScrollContainer
@onready var credits_text: RichTextLabel = $ScrollContainer/RichTextLabel

var credits_tween: Tween

const FONT_SIZE := 120
const BOLD_FONT_SIZE := 150
const CREDITS_DURATION := 50.0

const WIDTH := 3000
const HEIGHT := 5000


func _ready():
	visible = false

	black_background.color = Color.BLACK

	credits_text.bbcode_enabled = true
	credits_text.fit_content = true
	credits_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	credits_text.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	credits_text.add_theme_font_size_override("bold_font_size", BOLD_FONT_SIZE)

	setup_layout()


func setup_layout():
	# Todo gigante a mano.
	position = Vector2(-1000, -1000)
	size = Vector2(WIDTH, HEIGHT)

	black_background.position = Vector2.ZERO
	black_background.size = Vector2(WIDTH, HEIGHT)

	credits_scroll.position = Vector2.ZERO
	credits_scroll.size = Vector2(WIDTH, HEIGHT)

	credits_text.position = Vector2.ZERO
	credits_text.size = Vector2(WIDTH, HEIGHT * 2)
	credits_text.custom_minimum_size = Vector2(WIDTH, HEIGHT * 2)

	credits_scroll.scroll_vertical = 0


func _on_credits_button_pressed():
	play_credits()


func _on_close_credits_button_pressed():
	stop_credits()


func play_credits():
	if credits_tween:
		credits_tween.kill()

	setup_layout()

	visible = true
	credits_scroll.scroll_vertical = 0

	await get_tree().process_frame
	await get_tree().process_frame

	var max_scroll := credits_scroll.get_v_scroll_bar().max_value

	credits_tween = create_tween()
	credits_tween.tween_property(
		credits_scroll,
		"scroll_vertical",
		max_scroll,
		CREDITS_DURATION
	)

	await credits_tween.finished

	stop_credits()


func stop_credits():
	if credits_tween:
		credits_tween.kill()

	visible = false
	credits_scroll.scroll_vertical = 0
