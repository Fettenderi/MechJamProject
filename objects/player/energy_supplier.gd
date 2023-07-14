extends Area3D

@export var charge_time : float = 0.5

@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var charge_timer := $ChargeTimer

var can_charge := false
var target : Area3D

func _ready() -> void:
	charge_timer.connect("timeout", set_can_charge)
	connect("area_entered", target_entered_in_range)
	connect("area_exited", target_exited_from_range)

func target_entered_in_range(area: Area3D):
	target = area
	PlayerStats.can_discharge = false
	can_charge = true

func target_exited_from_range(_area: Area3D):
	target = null
	PlayerStats.can_discharge = true
	can_charge = false

func set_can_charge():
	if target is Area3D:
		can_charge = true
		charge_timer.start(charge_time)

func _physics_process(_delta):
	if can_charge:
		can_charge = false
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)
		
		charge_timer.start(charge_time)
		
		PlayerStats.energy = clamp(PlayerStats.energy + 5, 0, PlayerStats.max_energy)
