extends Area3D

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer
@onready var particles := $Particles

func _ready() -> void:
	connect("area_entered", end_attack)

func start_attack(particle_parameter: float = 1.0) -> void:
	duration_timer.start(duration_time)
	
func end_attack() -> void:
	queue_free()

func get_damage() -> float:
	return stats.get_damage(attack_type)
