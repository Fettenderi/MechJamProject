extends Area3D

@export var stats : Stats
@export var shields : Shield

@onready var shape := $Shape

@onready var has_shield := shields is Shield
@onready var is_enemy := stats != PlayerStats

var hit_sfx : StudioEventEmitter3D
var dead_sfx : StudioEventEmitter3D

func _ready():
	connect("area_entered", take_damage)
	if get_node_or_null("HitSfx"):
		hit_sfx = $HitSfx
	if get_node_or_null("DeadSfx"):
		dead_sfx = $DeadSfx
	if has_shield:
		shields.connect("no_shield", func(): has_shield = false)

func take_damage(area: Area3D):
	if has_shield:
		shields.health -= area.get_damage()
	else:
		stats.health -= area.get_damage()
	
	if not is_enemy:
		GameMachine.add_trauma(0.5)
	if hit_sfx:
		hit_sfx.play()
		

func get_damage() -> float:
	return stats.get_damage(Stats.AttackType.NORMAL)

func die():
	if is_enemy:
		PlayerStats.kills += 1
	
	shape.set_deferred("disabled", true)
	
	if dead_sfx:
		dead_sfx.play()
	
	await get_tree().create_timer(0.5).timeout
	get_parent().get_parent().queue_free()
