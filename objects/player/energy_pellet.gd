extends Area3D

@onready var primary_particles := $PrimaryParticles
@onready var secondary_particles := $SecondaryParticles
@onready var chaging_sfx := $ChargingSfx
@onready var despawn_timer := $DespawnTimer
@onready var shape := $Shape
@onready var mesh := $Mesh

var can_charge := false
var target : Area3D

func _ready() -> void:
	connect("area_entered", target_entered_in_range)
	despawn_timer.connect("timeout", queue_free)

func target_entered_in_range(area: Area3D):
	target = area
	can_charge = true
	primary_particles.call_deferred("set_emitting", true)
	secondary_particles.call_deferred("set_emitting", true)

func set_can_heal():
	if target is Area3D:
		can_charge = true

func _physics_process(_delta):
	if PlayerStats.energy == PlayerStats.max_energy:
		can_charge = false
#		chaging_sfx.stop()
		primary_particles.call_deferred("set_emitting", false)
		secondary_particles.call_deferred("set_emitting", false)
	
	if can_charge:
		chaging_sfx.play()
		can_charge = false
		PlayerStats.energy = clamp(PlayerStats.energy + PlayerStats.max_energy * 0.2, 0, PlayerStats.max_energy)
		mesh.visible = false
		shape.call_deferred("set_disabled", true)
		despawn_timer.start()
