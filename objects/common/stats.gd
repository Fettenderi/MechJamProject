class_name Stats

extends Node

@export_range(1,100) var max_health: float
@onready var health := max_health :
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			emit_signal("dead")
		emit_signal("health_changed", value)
		

@export_range(0.0,20.0) var damage: float

signal health_changed(value)
signal dead
