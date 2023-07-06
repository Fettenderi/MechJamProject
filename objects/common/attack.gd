extends Area3D

enum AttackType {
	NORMAL,
	DRILL,
	GUN,
	DUBSTEP
}

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

func _ready() -> void:
	duration_timer.connect("timeout", end_attack)

func start_attack() -> void:
	duration_timer.start(duration_time)
	
	shape.set_deferred("disabled", false)

func end_attack() -> void:
	shape.set_deferred("disabled", true)

func get_damage() -> float:
	return stats.get_damage(attack_type)
