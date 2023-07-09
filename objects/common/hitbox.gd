extends Area3D

@export var stats : Stats
@export var shields : Shield

@onready var has_shield := shields is Shield

func _ready():
	connect("area_entered", take_damage)
	if has_shield:
		shields.connect("no_shield", func(): has_shield = false)

func take_damage(area: Area3D):
	if has_shield:
		shields.health -= area.get_damage()
	else:
		stats.health -= area.get_damage()

func get_damage() -> float:
	return stats.get_damage(Stats.AttackType.NORMAL)

func die():
	PlayerStats.kills += 1
	get_parent().get_parent().queue_free()
