extends Node

@export_range(1,100) var max_health: int
var health: int:
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			emit_signal("dead")
		emit_signal("health_changed", value)
		

@export_range(1,20) var damage: int

signal health_changed(value)
signal dead
