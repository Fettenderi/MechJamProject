extends Stats

const MAX_KILLS_TO_WAVE = 5
const MAX_WAVES_TO_BOSS = 5

@export_range(1,100) var max_energy: float = 100:
	set(value):
		max_energy = value
		emit_signal("max_energy_changed", max_energy)
@onready var energy := max_energy :
	set(value):
		energy = clamp(value, 0, max_energy)
		if energy <= 0:
			emit_signal("dead")
		emit_signal("energy_changed", energy)

var can_discharge := true

@export var jump_charge_speed : float = 20
@export var max_jump_charge : float = 100
var jump_charge := 0.0 :
	set(value):
		if value == max_jump_charge and value != jump_charge:
			emit_signal("jump_fully_charged")
		jump_charge = value
		emit_signal("charge_jump", value)

@export var drill_usage_speed : float = 20
@export var min_drill_usage : float = 2
var drill_usage := 0.0 :
	set(value):
		drill_usage = value
		emit_signal("charge_drill_usage", value)


var unlocked_weapons : Array[int] = [0] :
	set(value):
		unlocked_weapons.append(value)

var available_weapons : Array[int] = [
	Stats.AttackType.NORMAL,
	Stats.AttackType.GUN
]

var run_selected_weapons : int = 0 :
	set(value):
		run_selected_weapons = value
		emit_signal("change_selected_weapon", value)

@export var weapon_energy_consumption : Array[float] = zeros(AttackType.size()) # :
#	set(value):
#		weapon_energy_consumption = value
#		emit_signal("weapon_ammos_updated", value)

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
signal max_energy_changed(value)
signal change_sele_cted_weapon(value)
signal charge_jump(value)
signal charge_drill_usage(value)
signal jump_fully_charged()
#signal weapon_ammos_updated(value)
signal kills_changed(value)
signal waves_changed(value)
signal summon_boss

func select_weapon(new: int, prev:= -1) -> void:
	if prev >= 0:
		available_weapons.remove_at(available_weapons.find(prev))
	available_weapons.append(new)
