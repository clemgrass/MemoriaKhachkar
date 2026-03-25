extends CSGBox3D

func play_note():
	if self.name == "do":
		$"316899JazTheMan2DoStretched".play()
	if self.name == "re":
		$"316909JazTheMan2ReStretched".play()
	if self.name == "mi":
		$"316907JazTheMan2MiStretched".play()
	if self.name == "fa":
		$"316905JazTheMan2FaStretched".play()
	if self.name == "sol":
		$"316911JazTheMan2SolStretched".play()
	if self.name == "la":
		$"316903JazTheMan2LaStretched".play()
	if self.name == "si":
		$"316910JazTheMan2SiStretched".play()
	if self.name == "do8":
		$"316900JazTheMan2DoStretchedOctave".play()
