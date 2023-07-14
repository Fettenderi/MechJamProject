class_name Shield

extends Node3D

const MAX_LEVELS = 3

@export_range(1, 3) var levels : int = 1

@export_range(1,100) var max_health: float
@onready var health := max_health :
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			health = max_health
			levels -= 1
			emit_signal("level_removed", levels)
			if levels == 0:
				emit_signal("no_shield")
				sfx_emitter.play()
				queue_free()
		emit_signal("health_changed", value)

@onready var sfx_emitter : StudioEventEmitter3D = $SFXEmitter

signal health_changed(value)
signal level_removed(value)
signal no_shield

