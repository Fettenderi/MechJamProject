class_name Attack

extends Area3D

@export var duration_time : float
@export var delay_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType
@export var particles_in_sync : bool = true

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer
@onready var delay_timer := $DelayTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var sfx_emitter := $SFXEmitter

@onready var max_prim_particles : int = primary_particles.amount
@onready var max_seco_particles : int = secondary_particles.amount

var attacking := false
var particle_parameters := 0.0

signal is_attacking

func _ready() -> void:
	delay_timer.connect("timeout", initiate_attack)
	duration_timer.connect("timeout", end_attack)

func start_attack(particle_parameter: float = 1.0) -> void:
	if not attacking:
		particle_parameters = particle_parameter
		delay_timer.start(delay_time)
		attacking = true
	else:
		if not particles_in_sync:
			emit_particles(particle_parameters)

func initiate_attack():
	emit_signal("is_attacking")
	sfx_emitter.play()
	duration_timer.start(duration_time)
	
	emit_particles(particle_parameters)
	
	shape.set_deferred("disabled", false)

func end_attack() -> void:
	attacking = false
	delay_timer.stop()
	duration_timer.stop()
	shape.set_deferred("disabled", true)

func emit_particles(particle_parameter: float = 1.0) -> void:
	primary_particles.amount = particle_parameter * max_prim_particles
	secondary_particles.amount = particle_parameter * max_seco_particles
	
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)

func get_damage() -> float:
	return stats.get_damage(attack_type)
