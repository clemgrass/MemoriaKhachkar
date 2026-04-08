extends CSGBox3D

@onready var terminal_camera: Camera3D = $Camera3D
@onready var terminal_input: LineEdit = $CanvasLayer/LineEdit
@onready var terminal_instructions: Label = $CanvasLayer/Label

var solution = "armenian khachkars!"

func _ready():
	terminal_input.hide()
	terminal_instructions.hide()

func answer(text) -> bool:
	if text == solution:
		self.use_collision = false
		return true
	else:
		return false
		
func khackharSolution() -> void:
	$"../../windows/KhachkarWinProtect5".visible = false
	$"../../AnimationPlayer".play("windows_r3")
	await $"../../AnimationPlayer".animation_finished
	$"../../Khachkar3/collisionKhachkar3/khachkarColl".disabled = false
