extends CSGBox3D

func play_note():
	if self.name == "do":
		$"316899JazTheMan2DoStretched".play()
		$"../..".note_played("do")
	if self.name == "re":
		$"316909JazTheMan2ReStretched".play()
		$"../..".note_played("re")
	if self.name == "mi":
		$"316907JazTheMan2MiStretched".play()
		$"../..".note_played("mi")
	if self.name == "fa":
		$"316905JazTheMan2FaStretched".play()
		$"../..".note_played("fa")
	if self.name == "sol":
		$"316911JazTheMan2SolStretched".play()
		$"../..".note_played("sol")
	if self.name == "la":
		$"316903JazTheMan2LaStretched".play()
		$"../..".note_played("la")
	if self.name == "si":
		$"316910JazTheMan2SiStretched".play()
		$"../..".note_played("si")
	if self.name == "do8":
		$"316900JazTheMan2DoStretchedOctave".play()
		$"../..".note_played("do8")
