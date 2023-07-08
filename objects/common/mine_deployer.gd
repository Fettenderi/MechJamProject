extends Node3D

@export var duration_time : float
@export var stats : Stats
@export_group("Mine")
@export var mine : PackedScene
@export_flags_3d_physics var layer : int
@export_flags_3d_physics var mask : int
@export var attack_type : Stats.AttackType

@onready var reload_timer := $ReloadTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

var can_deploy := true

func _ready() -> void:
	reload_timer.connect("timeout", end_attack)

func start_attack() -> void:
	if can_deploy:
		var mine_node : Mine = mine.instantiate()
		
		if stats == PlayerStats:
			stats.weapon_ammos[Stats.AttackType.MINE] -= 1
			# Aggiungere shake screen effect

		mine_node.position = global_position
		mine_node.collision_layer = layer
		mine_node.collision_mask = mask
		
		GameMachine.add_prop(mine_node)
		reload_timer.start(duration_time)
		can_deploy = false
		
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)

func end_attack() -> void:
	can_deploy = true

func get_damage() -> float:
	return stats.get_damage(attack_type)
