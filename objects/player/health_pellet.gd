extends Area3D

@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var healing_sfx := $HealingSfx
@onready var despawn_timer := $DespawnTimer
@onready var shape := $Shape
@onready var mesh := $Mesh

var can_heal := false
var target : Area3D

func _ready() -> void:
	connect("area_entered", target_entered_in_range)
	despawn_timer.connect("timeout", queue_free)

func target_entered_in_range(area: Area3D):
	target = area
	can_heal = true
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)

func set_can_heal():
	if target is Area3D:
		can_heal = true

func _physics_process(_delta):
	if PlayerStats.health == PlayerStats.max_health:
		can_heal = false
		healing_sfx.stop()
		primary_particles.call_deferred("set_emitting", false)
		secondary_particles.call_deferred("set_emitting", false)
	
	if can_heal:
		healing_sfx.play()
		can_heal = false
		PlayerStats.health = clamp(PlayerStats.health + PlayerStats.max_health * 0.2, 0, PlayerStats.max_health)
		mesh.visible = false
		shape.call_deferred("set_disabled", true)
		despawn_timer.start()
