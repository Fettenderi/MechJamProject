extends Choice

func choice_made():
	PlayerStats.max_health += 20 
	PlayerStats.health = PlayerStats.max_health
