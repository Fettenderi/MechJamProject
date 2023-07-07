class_name Projectile

extends Area3D

const BULLET_SPEED = 20.0

@export_range(0.0, 10.0) var despawn_time : float
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var despawn_timer := $DespawnTimer
@onready var particles := $Particles

var stats : Stats
var direction := Vector3.FORWARD

func _ready() -> void:
	connect("area_entered", despawn)
	despawn_timer.connect("timeout", despawn)

func _physics_process(delta):
	position += direction * BULLET_SPEED * delta

func start_attack() -> void:
	despawn_timer.start(despawn_time)
	
func despawn(_area: Area3D = null) -> void:
	queue_free()

func get_damage() -> float:
	return stats.get_damage(attack_type)
