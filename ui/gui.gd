extends Control

@export var color_low: Color
@export var color_high: Color
@export var max_size: Vector2 = Vector2(200, 20)

@onready var health_bar:= $HealthBar
@onready var energy_bar:= $EnergyBar
@onready var weapon:= $Weapon
@onready var jump_charge:= $JumpCharge

func remap_color(value: float, istart: float, istop: float, ostart: Color, ostop: Color) -> Color:
	return Color(remap(value, istart, istop, ostart.r, ostop.r), remap(value, istart, istop, ostart.g, ostop.g), remap(value, istart, istop, ostart.b, ostop.b))

func _ready():
	PlayerStats.connect("health_changed", update_health)
	PlayerStats.connect("energy_changed", update_energy)
	PlayerStats.connect("change_selected_weapon", update_selected_weapon)
	PlayerStats.connect("charge_jump", update_jump_charge)
	
	weapon.text = "Normal"
	
	health_bar.size = max_size
	health_bar.color = color_high

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
	jump_charge.text = str(new_charge)
