extends Node3D

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats
@export_group("Projectile")
@export var projectile : PackedScene
@export_flags_3d_physics var layer : int
@export_flags_3d_physics var mask : int
@export var attack_type : Stats.AttackType

@onready var reload_timer := $ReloadTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

var can_shoot := true

func _ready() -> void:
	reload_timer.connect("timeout", end_attack)

func start_attack() -> void:
	if can_shoot:
		var projectile_node : Projectile = projectile.instantiate()
		
		if stats == PlayerStats:
			stats.weapon_ammos[Stats.AttackType.GUN] -= 1
			# Aggiungere shake screen effect

		projectile_node.position = global_position
		projectile_node.direction = Vector3(cos(global_rotation.y), 0, -sin(global_rotation.y))
		projectile_node.stats = stats 
		projectile_node.collision_layer = layer
		projectile_node.collision_mask = mask
#		projectile_node.direction = rotation
		
		GameMachine.add_projectile(projectile_node)
		reload_timer.start(duration_time)
		can_shoot = false
		
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)

func end_attack() -> void:
	can_shoot = true

func get_damage() -> float:
	return stats.get_damage(attack_type)
