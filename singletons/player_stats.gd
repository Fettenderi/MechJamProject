extends Stats

const MAX_KILLS_TO_WAVE = 5
const MAX_WAVES_TO_BOSS = 5

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

@export var jump_charge_speed : float = 20
@export var max_jump_charge : float = 200
var jump_charge := 0.0 :
	set(value):
		if value == max_jump_charge and value != jump_charge:
			emit_signal("jump_fully_charged")
		jump_charge = value
		emit_signal("charge_jump", value)

@export var drill_gun_charge_speed : float = 20
@export var min_drill_gun_charge : float = 5
var drill_gun_charge := 0.0 :
	set(value):
		drill_gun_charge = value
		emit_signal("charge_drill_gun", value)


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
		if kills >= MAX_KILLS_TO_WAVE:
			waves += 1
			kills = 0
		emit_signal("kills_changed", value)

var waves : int = 0 :
	set(value):
		waves = value
		if waves >= MAX_WAVES_TO_BOSS:
			emit_signal("summon_boss")
		emit_signal("waves_changed", value)

signal energy_changed(value)
signal change_selected_weapon(value)
signal charge_jump(value)
signal charge_drill_gun(value)
signal jump_fully_charged()
signal weapon_ammos_updated(value)
signal kills_changed(value)
signal waves_changed(value)
signal summon_boss

func menu_select_weapon(new: int, prev:= -1) -> void:
	if prev >= 0:
		menu_selected_weapons.remove_at(menu_selected_weapons.find(prev))
	menu_selected_weapons.append(new)
