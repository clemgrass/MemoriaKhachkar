extends CSGBox3D

@onready var terminal_camera: Camera3D = $Camera3D
@onready var terminal_input: LineEdit = $CanvasLayer/LineEdit

var solution = "armenian khachkars!"

func _ready():
	terminal_input.hide()


func answer(text) -> bool:
	if text == solution:
		self.use_collision = false
		#TODO cosas con el khachkar
		$"../../windows/KhachkarWinProtect5".visible = false
		$"../../Khachkar3/collision_khachkar".use_collision = true
		$"../../AnimationPlayer".play("windows_r3")
		return true
	else:
		return false
