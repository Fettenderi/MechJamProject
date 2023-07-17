extends Node3D

@export var duration_time : float
@export var delay_time : float
@export var stats : Stats
@export_group("Projectile")
@export var projectile : PackedScene
@export_flags_3d_physics var layer : int
@export_flags_3d_physics var mask : int
@export var attack_type : Stats.AttackType
@export var speed := 20

@onready var reload_timer := $ReloadTimer
@onready var delay_timer := $DelayTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var sfx_emitter := $SFXEmitter

var can_shoot := true

signal is_attacking

func _ready() -> void:
	reload_timer.connect("timeout", end_attack)
	delay_timer.connect("timeout", initiate_attack)

func start_attack() -> void:
	if can_shoot:
		emit_signal("is_attacking")
		delay_timer.start(delay_time)
		can_shoot = false

func initiate_attack():
	var projectile_node : Projectile = projectile.instantiate()

	sfx_emitter.play()
	projectile_node.position = global_position
	projectile_node.direction = Vector3(cos(global_rotation.y), 0, -sin(global_rotation.y))
	projectile_node.stats = stats 
	projectile_node.collision_layer = layer
	projectile_node.collision_mask = mask
	projectile_node.speed = speed
	
	GameMachine.add_prop(projectile_node)
	reload_timer.start(duration_time)
	
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)

func end_attack() -> void:
	delay_timer.stop()
	sfx_emitter.stop()
	reload_timer.stop()
	can_shoot = true

func get_damage() -> float:
	return stats.get_damage(attack_type)
