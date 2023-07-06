extends Area3D

@export var stats : Stats

func _ready():
	self.connect("area_entered", take_damage)

func take_damage(area: Area3D):
	stats.health -= area.get_damage()

func get_damage() -> float:
	return stats.get_damage(Stats.AttackType.NORMAL)

func die():
	get_parent().queue_free()
