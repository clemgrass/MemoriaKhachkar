extends Node3D

var photo_order_p1: Array 
var photo_order_p2: Array 
var photo_order_p3: Array
var part1_pos: int = 0
var part2_pos: int = 0
var part3_pos: int = 0
var curr_solution: Array = [0,0,0]
var puzzle_solution: Array = [5, 2, 8]
var solved: bool = false

func _ready() -> void:
	photo_order_p1 = [$part1/photo2,$part1/photo7 ,$part1/photo1 ,$part1/photo5 ,$part1/photo9 ,$part1/photo4 ,$part1/photo3 ,$part1/photo6 ,$part1/photo8 ]
	photo_order_p2 = [$part2/photo2,$part2/photo7 ,$part2/photo1 ,$part2/photo5 ,$part2/photo9 ,$part2/photo4 ,$part2/photo3 ,$part2/photo6 ,$part2/photo8 ]
	photo_order_p3 = [$part3/photo2,$part3/photo7 ,$part3/photo1 ,$part3/photo5 ,$part3/photo9 ,$part3/photo4 ,$part3/photo3 ,$part3/photo6 ,$part3/photo8 ]
	
	photo_order_p1[part1_pos].visible = true
	photo_order_p2[part2_pos].visible = true
	photo_order_p3[part3_pos].visible = true
	
	
func check_solution():
	if curr_solution[0] == puzzle_solution[0] and curr_solution[1] == puzzle_solution[1] and curr_solution[2] == puzzle_solution[2]:
		solved = true
		$"../windows/KhachkarWinProtect5".visible = false
		$"../khachkar_1/collisionKhachkar1".use_collision = true
		$AnimationPlayer.play("windows_down")

func part1_photos(next: int) -> void:
	if not solved:
		photo_order_p1[part1_pos].visible = false
		part1_pos += next
		if part1_pos == len(photo_order_p1):
			part1_pos = 0
		elif part1_pos == -1:
			part1_pos = len(photo_order_p1) - 1
		photo_order_p1[part1_pos].visible = true
		curr_solution[0] = part1_pos
		print(curr_solution)
		check_solution()
	
func part2_photos(next: int) -> void:
	if not solved:
		photo_order_p2[part2_pos].visible = false
		part2_pos += next
		if part2_pos == len(photo_order_p2):
			part2_pos = 0
		elif part2_pos == -1:
			part2_pos = len(photo_order_p2) - 1
		photo_order_p2[part2_pos].visible = true
		curr_solution[1] = part2_pos
		print(curr_solution)
		check_solution()

func part3_photos(next: int) -> void:
	if not solved:
		photo_order_p3[part3_pos].visible = false
		part3_pos += next
		if part3_pos == len(photo_order_p3):
			part3_pos = 0
		elif part3_pos == -1:
			part3_pos = len(photo_order_p3) - 1
		photo_order_p3[part3_pos].visible = true
		curr_solution[2] = part3_pos
		print(curr_solution)
		check_solution()
