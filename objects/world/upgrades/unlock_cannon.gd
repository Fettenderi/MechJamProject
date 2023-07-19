extends Choice

func choice_made():
	PlayerStats.available_weapons.append(Stats.AttackType.FOTONIC)
	GameMachine.emit_signal("new_weapon_unlocked")
