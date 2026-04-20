extends Node3D


var letters_map: Dictionary
var letters_num: Dictionary

func _ready() -> void:
	letters_map = {
		"tColl": $"../t1",
		"tColl1": $"../t2",
		"tColl2": $"../t3",
		"tColl3": $"../t4",
		"tColl4": $"../t5",
		"tColl5": $"../t6",
		"tColl6": $"../t7",
		"tColl7": $"../t8",
		"tColl8": $"../t9",
		"tColl9": $"../t10",
		"tColl10": $"../t11",
		"tColl11": $"../t12"
	}
	letters_num = {
		"tColl": 0,
		"tColl1": 1,
		"tColl2": 2,
		"tColl3": 3,
		"tColl4": 4,
		"tColl5": 5,
		"tColl6": 6,
		"tColl7": 7,
		"tColl8": 8,
		"tColl9": 9,
		"tColl10": 10,
		"tColl11": 11
	}

func on_click_letter(sequence):
	print(sequence)
	print(sequence[letters_num[self.name]])
	if not letters_map[self.name].visible and sequence[letters_num[self.name]]:
		letters_map[self.name].visible = true
		sequence[letters_num[self.name] + 1] = true
		print(sequence)
		return sequence
	return sequence
