class_name Projectile

extends Area3D


@export_range(0.0, 10.0) var despawn_time : float
@export var attack_type : Stats.AttackType

@onready var shape := $Shape
@onready var despawn_timer := $DespawnTimer
@onready var particles := $Particles
@onready var damage := stats.get_damage(attack_type)

var speed := 10.0
var stats : Stats
var direction := Vector3.FORWARD

func _ready() -> void:
	connect("area_entered", despawn)
	despawn_timer.connect("timeout", despawn)
	despawn_timer.start(despawn_time)

func _enter_tree():
	look_at(direction + global_position, Vector3.UP)
	
func _physics_process(delta):
	position += direction * speed * delta

func despawn(_area : Area3D = null):
	queue_free()

func get_damage() -> float:
	return damage
