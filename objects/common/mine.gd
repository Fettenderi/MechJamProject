class_name Mine

extends Area3D

@export var damage : float = 1.0
@export var despawn_time : float = 1.0

@onready var shape := $Shape
@onready var mesh := $Mesh
@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var despawn_timer := $DespawnTimer
@onready var sfx_emitter : StudioEventEmitter3D = $SFXEmitter

@onready var max_prim_particles : int = primary_particles.amount
@onready var max_seco_particles : int = secondary_particles.amount


func _ready() -> void:
	despawn_timer.connect("timeout", queue_free)
	connect("area_entered", explode)
	if position.y > 1:
		queue_free()

func explode(_area: Area3D = null) -> void:
	GameMachine.add_trauma(3)
	sfx_emitter.play()
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)
	mesh.visible = false
	shape.call_deferred("set_disabled", true)
	despawn_timer.start(despawn_time)
	# Inserire shake screen

func get_damage() -> float:
	return damage
