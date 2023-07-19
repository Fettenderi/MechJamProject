extends Area3D

@export var charge_time : float = 0.5
@export var is_active := false

@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var charge_timer := $ChargeTimer
@onready var charging_sfx := $ChargingSfx

var can_charge := false
var target : Area3D
var once_charged := false

func _ready() -> void:
	charge_timer.connect("timeout", set_can_charge)
	connect("area_entered", target_entered_in_range)
	connect("area_exited", target_exited_from_range)

func target_entered_in_range(area: Area3D):
	if is_active:
		target = area
		PlayerStats.can_discharge = false
		can_charge = true
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)

func target_exited_from_range(_area: Area3D):
	if is_active:
		once_charged = false
		target = null
		PlayerStats.can_discharge = true
		can_charge = false
		charging_sfx.stop()
		primary_particles.call_deferred("set_emitting", false)
		secondary_particles.call_deferred("set_emitting", false)

func set_can_charge():
	if target is Area3D and is_active:
		can_charge = true
		charge_timer.start(charge_time)

func _physics_process(_delta):
	if is_active:
		if PlayerStats.energy == PlayerStats.max_energy:
			can_charge = false
			charging_sfx.stop()
			primary_particles.call_deferred("set_emitting", false)
			secondary_particles.call_deferred("set_emitting", false)
		
		if can_charge:
			if not once_charged:
				charging_sfx.play()
				once_charged = true
			can_charge = false
			charge_timer.start(charge_time)
			
			PlayerStats.energy = clamp(PlayerStats.energy + 5, 0, PlayerStats.max_energy)
