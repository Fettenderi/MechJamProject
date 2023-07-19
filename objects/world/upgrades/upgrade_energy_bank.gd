extends Choice

func choice_made():
	PlayerStats.max_energy += 20
	PlayerStats.energy = PlayerStats.max_energy
