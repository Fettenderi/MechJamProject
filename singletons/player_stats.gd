extends Stats

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

var can_discharge := false

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

@export var fotonic_usage_speed : float = 20
@export var min_fotonic_usage : float = 4
var fotonic_usage := 0.0 :
	set(value):
		fotonic_usage = value
		emit_signal("charge_fotonic_usage", value)

var unlocked_weapons : Array[int] = [0] :
	set(value):
		unlocked_weapons.append(value)

var available_weapons : Array[int] = [
	Stats.AttackType.NORMAL,
	Stats.AttackType.GUN,
	Stats.AttackType.DRILL,
	Stats.AttackType.FOTONIC
]

var selected_weapon : int = 0 :
	set(value):
		selected_weapon = value
		emit_signal("change_selected_weapon", value)

@export var weapon_energy_consumption : Array[float] = zeros(AttackType.size()) # :
#	set(value):
#		weapon_energy_consumption = value
#		emit_signal("weapon_ammos_updated", value)

var kills : int = 0 :
	set(value):
		kills = value
		emit_signal("kills_changed", value)

signal energy_changed(value)
signal max_energy_changed(value)

signal change_selected_weapon(value)

signal charge_jump(value)
signal jump_fully_charged()

signal charge_drill_usage(value)
signal charge_fotonic_usage(value)

signal kills_changed(value)

func select_weapon(new: int, prev:= -1) -> void:
	if prev >= 0:
		available_weapons.remove_at(available_weapons.find(prev))
	available_weapons.append(new)
