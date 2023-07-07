extends Node3D

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats
@export var attack_type : Stats.AttackType

@onready var reload_timer := $ReloadTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

@export var projectile : PackedScene

var can_shoot := true

func _ready() -> void:
	reload_timer.connect("timeout", end_attack)

func start_attack() -> void:
	if can_shoot:
		WorldManager.add_projectile(projectile)
		reload_timer.start(duration_time)
		can_shoot = false
		
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)


func end_attack() -> void:
	can_shoot = true

func get_damage() -> float:
	return stats.get_damage(attack_type)
