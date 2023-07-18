extends Projectile

@onready var actual_damage_area := $ActualDamageArea
@onready var actual_damage_shape := $ActualDamageArea/Shape
@onready var area_particles := $AreaParticles

func _ready() -> void:
	connect("area_entered", activate)
	despawn_timer.connect("timeout", despawn)
	despawn_timer.start(despawn_time)
	
	actual_damage_area.collision_layer = collision_layer
	actual_damage_area.collision_mask = collision_mask

func activate(_area: Area3D = null):
	actual_damage_shape.call_deferred("set_disabled", false)
	area_particles.call_deferred("set_emitting", true)
	particles.call_deferred("set_emitting", false)
	speed = 0

func despawn(_area : Area3D = null):
	queue_free()

func get_damage() -> float:
	return 0
