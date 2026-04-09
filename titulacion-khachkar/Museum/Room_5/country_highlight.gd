extends CSGPolygon3D

var countries_num = { "USAColl": 1, "ChileColl": 2, "FranceColl": 3, "RussiaColl": 4, "AustraliaColl": 5, "ArmeniaColl": 6  }

func country_click_highlight():
	var mat = self.material
	mat.albedo_color = Color(0, 1, 0)
	mat.emission = Color(0, 1, 0)
	$"../../..".correct_country(countries_num[self.name])

func country_wrong_highlight():
	var mat = self.material
	mat.albedo_color = Color(1,0,0)
	mat.emission = Color(1,0,0)
	await get_tree().create_timer(0.5).timeout
	$"../../..".reset_colors()
