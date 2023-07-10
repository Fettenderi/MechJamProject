extends Control

@export var color_low: Color
@export var color_high: Color
@export var max_size: Vector2 = Vector2(200, 20)

@onready var health_bar:= $HealthBar
@onready var energy_bar:= $EnergyBar
@onready var weapon:= $Container/Weapon
@onready var jump_charge:= $Container/JumpCharge
@onready var kill_counter:= $KillCounter
@onready var drill_gun_charge:= $Container/DrillGunCharge

@export_group("Switches")
@export var disable_health := false
@export var disable_energy := false
@export var disable_weapon := false
@export var disable_jump := false
@export var disable_drill_gun := false
@export var disable_kills := false

func remap_color(value: float, istart: float, istop: float, ostart: Color, ostop: Color) -> Color:
	return Color(remap(value, istart, istop, ostart.r, ostop.r), remap(value, istart, istop, ostart.g, ostop.g), remap(value, istart, istop, ostart.b, ostop.b))

func _ready():
	PlayerStats.connect("health_changed", update_health)
	PlayerStats.connect("energy_changed", update_energy)
	PlayerStats.connect("change_selected_weapon", update_selected_weapon)
	PlayerStats.connect("charge_jump", update_jump_charge)
	PlayerStats.connect("charge_drill_gun", update_drill_gun_charge)
	PlayerStats.connect("kills_changed", update_kill_counter)
	
	weapon.text = "Normal"
	kill_counter.text = "0"
#	drill_gun_charge.text = "0"
#	jump_charge.text = "0"
	
	health_bar.size = max_size
	health_bar.color = color_high
	
	if disable_health:
		health_bar.visible = false
	if disable_energy:
		energy_bar.visible = false
	if disable_weapon:
		weapon.visible = false
	if disable_jump:
		jump_charge.visible = false
	if disable_kills:
		kill_counter.visible = false
	if disable_drill_gun:
		drill_gun_charge.visible = false

func update_health(new_health):
	health_bar.size.x = (float(new_health) / float(PlayerStats.max_health)) * float(max_size.x)
	
	@warning_ignore("integer_division")
	health_bar.color = remap_color(new_health, PlayerStats.max_health / 3, PlayerStats.max_health * 2 / 3, color_low, color_high)

func update_energy(new_energy):
	energy_bar.size.x = (float(new_energy) / float(PlayerStats.max_energy)) * float(max_size.x)

func update_selected_weapon(new_selected_weapon):
	match new_selected_weapon:
		Stats.AttackType.NORMAL:
			weapon.text = "Normal"
		Stats.AttackType.DRILL:
			weapon.text = "Drill"
		Stats.AttackType.GUN:
			weapon.text = "Gun"
		Stats.AttackType.DUBSTEP:
			weapon.text = "Dubstep"
		Stats.AttackType.POUND:
			weapon.text = "Pound"

func update_jump_charge(new_charge):
	jump_charge.text = str(int(new_charge))

func update_drill_gun_charge(new_drill_gun):
	drill_gun_charge.text = str(int(new_drill_gun))

func update_kill_counter(new_kills):
	kill_counter.text = str(new_kills)
