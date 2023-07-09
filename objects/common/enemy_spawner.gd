extends Node3D

@export var normal_enemies_pool : Array[PackedScene]
@export var special_enemies_pool : Array[PackedScene]
@export var enemy_amount : int

@onready var deploy_timer := $DeployTimer
@onready var despawn_timer := $DespawnTimer
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles

var can_deploy := true
var deployied_enemies := 0

func _ready() -> void:
	deploy_timer.connect("timeout", end_attack)
	despawn_timer.connect("timeout", despawn)

func start_attack() -> void:
	if can_deploy:
		can_deploy = false
		
		var enemy_node : CharacterBody3D
		
		if deployied_enemies < enemy_amount:
			deploy_timer.start()
			enemy_node = normal_enemies_pool.pick_random().instantiate()
		else:
			despawn_timer.start()
			enemy_node = special_enemies_pool.pick_random().instantiate()
		
		enemy_node.position = global_position
		
		GameMachine.add_entity(enemy_node)
		
		primary_particles.call_deferred("set_emitting", true)
		secondary_particles.call_deferred("set_emitting", true)
		deployied_enemies += 1

func end_attack() -> void:
	can_deploy = true

func despawn() -> void:
	get_parent().get_parent().queue_free()
