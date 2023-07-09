extends Stats

@export_range(1,100) var max_energy: float = 100
@onready var energy := max_energy :
	get:
		return energy
	set(value):
		energy = clamp(value, 0, max_energy)
		if energy <= 0:
			emit_signal("dead")
		emit_signal("energy_changed", energy)

var can_discharge := true

@export var jump_charge_speed : float = 0.5
@export var max_jump_charge : float = 200
var jump_charge := 0.0 :
	set(value):
		if value == max_jump_charge and value != jump_charge:
			emit_signal("jump_fully_charged")
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

@export var weapon_ammos : Array[float] = zeros(AttackType.size()) :
	set(value):
		weapon_ammos = value
		emit_signal("weapon_ammos_updated", value)

var kills : int = 0 :
	set(value):
		kills = value
		emit_signal("kills_changed", value)

signal energy_changed(value)
signal change_selected_weapon(value)
signal charge_jump(value)
signal jump_fully_charged()
signal weapon_ammos_updated(value)
signal kills_changed(value)

func menu_select_weapon(new: int, prev:= -1) -> void:
	if prev >= 0:
		menu_selected_weapons.remove_at(menu_selected_weapons.find(prev))
	menu_selected_weapons.append(new)
