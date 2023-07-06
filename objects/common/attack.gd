extends Area3D

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

@onready var max_prim_particles : int = primary_particles.amount
@onready var max_seco_particles : int = secondary_particles.amount

func _ready() -> void:
	duration_timer.connect("timeout", end_attack)

func start_attack(particle_parameter: float = 1.0) -> void:
	duration_timer.start(duration_time)
	
	primary_particles.amount = particle_parameter * max_prim_particles
	secondary_particles.amount = particle_parameter * max_seco_particles
	
	primary_particles.restart()
	secondary_particles.restart()
	
	shape.set_deferred("disabled", false)

func end_attack() -> void:
	shape.set_deferred("disabled", true)

func get_damage() -> float:
	return stats.get_damage(attack_type)
