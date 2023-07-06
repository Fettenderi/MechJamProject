extends Stats

@export var jump_charge_speed : float = 0.5
var jump_charge := 0.0 :
	set(value):
		jump_charge = value
		emit_signal("charge_jump", value)

var unlocked_weapons : Array[int] = [0] :
	set(value):
		unlocked_weapons.append(value)

var menu_selected_weapons : Array[int] = [0, 1, 2]
var run_selected_weapons : int = 0 :
	set(value):
		run_selected_weapons = value
		emit_signal("change_selected_weapon", value)

signal change_selected_weapon(value)
signal charge_jump(value)

func menu_select_weapon(new: int, prev:= -1) -> void:
	if prev >= 0:
		menu_selected_weapons.remove_at(menu_selected_weapons.find(prev))
	menu_selected_weapons.append(new)
