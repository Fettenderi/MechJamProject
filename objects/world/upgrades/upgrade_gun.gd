extends Choice

func choice_made():
	PlayerStats.damage_boosts[Stats.AttackType.GUN] += PlayerStats.damage_boosts[Stats.AttackType.GUN] * 0.4
	PlayerStats.damage_boosts[Stats.AttackType.GUN] -= PlayerStats.damage_boosts[Stats.AttackType.GUN] * 0.1
