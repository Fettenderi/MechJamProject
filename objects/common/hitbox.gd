extends Area3D

@export var stats : Stats
@export var shields : Shield

@onready var has_shield := shields is Shield
@onready var is_enemy := stats != PlayerStats

var hit_sfx : StudioEventEmitter3D
var dead_sfx : StudioEventEmitter3D

func _ready():
	connect("area_entered", take_damage)
	if hit_sfx:
		hit_sfx = $HitSfx
	if dead_sfx:
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
		hit_sfx.play()
		

func get_damage() -> float:
	return stats.get_damage(Stats.AttackType.NORMAL)

func die():
	if is_enemy:
		PlayerStats.kills += 1
	dead_sfx.play()
	get_parent().get_parent().queue_free()
