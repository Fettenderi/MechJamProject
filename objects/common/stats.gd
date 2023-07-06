class_name Stats

extends Node

enum AttackType {
	NORMAL,
	DRILL,
	GUN,
	DUBSTEP,
	POUND
}

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
var damage_boosts : Array[float] = [0,0,0,0,0]

signal health_changed(value)
signal dead

func get_damage(type: AttackType) -> float:
	var result := damage
	
	match type:
		AttackType.DRILL:
			result = result * 1.2
		AttackType.GUN:
			result = result * 1.4
		AttackType.DUBSTEP:
			result = result * 1.7
		AttackType.POUND:
			result = result * 1.5
		_:
			pass
	
	return result + damage_boosts[type]
