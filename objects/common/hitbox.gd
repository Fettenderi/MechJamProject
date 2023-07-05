extends Area3D

@export var stats : Stats

func _ready():
	self.connect("area_entered", take_damage)
#	stats.connect("dead", die)

func take_damage(area: Area3D):
	stats.health -= area.get_stats().damage

func die():
	get_parent().queue_free()
