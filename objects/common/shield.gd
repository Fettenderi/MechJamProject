class_name Shield

extends Node3D

const MAX_LEVELS = 3
const MAX_RADIUS_BONUS = 1

@export_range(1, 3) var levels : int

@export_range(1,100) var max_health: float
@onready var health := max_health :
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			health = max_health
			get_child(levels - 1).queue_free()
			levels -= 1
			emit_signal("level_removed", levels)
			if levels == 0:
				emit_signal("no_shield")
				queue_free()
		emit_signal("health_changed", value)

signal health_changed(value)
signal level_removed(value)
signal no_shield

func _ready():
	var i := 0
	for child in get_children():
		var new_radius : float = 1.5 + float(MAX_RADIUS_BONUS) * i / float(MAX_LEVELS)
		child.mesh.set_deferred("radius", new_radius)
		child.mesh.set_deferred("height", 2 * new_radius)
		i += 1
