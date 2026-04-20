extends Node3D

var countries: Array
var solution: Array = [false, false, false, false, false]

func _ready() -> void:
	countries = [$countriesMesh/USA/USAColl, $countriesMesh/Chile/ChileColl, $countriesMesh/France/FranceColl, $countriesMesh/Russia/RussiaColl, $countriesMesh/Australia/AustraliaColl, $countriesMesh/Armenia/ArmeniaColl, $countriesMesh/Madagascar/MadagascarColl, $countriesMesh/Uruguay/UruguayColl, $countriesMesh/Nigeria/NigeriaColl, $countriesMesh/India/InidaColl, $countriesMesh/NewZealand/NewZealandColl]

func reset_colors():
	for country in countries:
		var mat = country.material
		mat.albedo_color = Color(1,1,1)
		mat.emission = Color(1,1,1)
	for i in range(solution.size()):
		solution[i] = false
	print(solution)

func correct_country(numC: int):
	if numC == 6:
		solved_puzzle()
	else:
		solution[numC-1] = true
		print(solution)
		check_solution()

func check_solution():
	for sol in solution:
		if not sol:
			return
	for country in countries:
		country.use_collision = false
	$countriesMesh/Armenia/ArmeniaColl.visible = true
	$countriesMesh/Armenia/ArmeniaColl.use_collision = true
	$khachkar5maninfold/k1.visible = false
	$khachkar5maninfold/k2.visible = false
	$khachkar5maninfold/k3.visible = false
	$khachkar5maninfold/k4.visible = false
	$khachkar5maninfold/k5.visible = false
	$Khachkar5.visible = true

func solved_puzzle():
	$AnimationPlayer.play("khachkar_fall")
	await $AnimationPlayer.animation_finished
	$Khachkar5/collisionKhachkar5/khachkarColl.disabled = false
	
	
	
