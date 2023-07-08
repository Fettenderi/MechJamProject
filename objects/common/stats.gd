class_name Stats

extends Node

enum AttackType {
	NORMAL,
	DRILL,
	GUN,
	DUBSTEP,
	MINE,
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
var damage_boosts : Array[float] = zeros(AttackType.size())

@export var speed: float

signal health_changed(value)
signal dead

func zeros(n: int) -> Array[float]:
	var result : Array[float] = []
	for i in range(n):
		result.append(0)
	return result

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
