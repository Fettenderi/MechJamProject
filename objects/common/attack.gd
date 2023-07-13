class_name Attack

extends Area3D

@export var duration_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

@onready var max_prim_particles : int = primary_particles.amount
@onready var max_seco_particles : int = secondary_particles.amount

var attacking := false

signal is_attacking

func _ready() -> void:
	duration_timer.connect("timeout", end_attack)

func start_attack(particle_parameter: float = 1.0) -> void:
	if not attacking:
		emit_signal("is_attacking")
		attacking = true
		duration_timer.start(duration_time)
		
		emit_particles(particle_parameter)
		
		shape.set_deferred("disabled", false)

func end_attack() -> void:
	attacking = false
	shape.set_deferred("disabled", true)

func emit_particles(particle_parameter: float = 1.0) -> void:
	primary_particles.amount = particle_parameter * max_prim_particles
	secondary_particles.amount = particle_parameter * max_seco_particles
	
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)

func get_damage() -> float:
	return stats.get_damage(attack_type)
