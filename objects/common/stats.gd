class_name Stats

extends Node

enum AttackType {
	NORMAL,
	GUN,
	DRILL,
	FOTONIC,
	MINE,
	POUND
}

@export_range(1,100) var max_health: float:
	set(value):
		max_health = value
		emit_signal("max_health_changed", max_health)
@onready var health := max_health :
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			emit_signal("dead")
		emit_signal("health_changed", value)

@export_range(0.0,20.0) var damage: float
@export var damage_boosts : Array[float] = zeros(AttackType.size())

@export var speed: float

signal health_changed(value)
signal max_health_changed(value)
signal dead

func zeros(n: int) -> Array[float]:
	var result : Array[float] = []
	for i in range(n):
		result.append(0)
	return result

func get_damage(type: AttackType) -> float:
	var result := damage
	
	match type:
		AttackType.GUN:
			result = result * 2
		AttackType.DRILL:
			result = result * 4
		AttackType.FOTONIC:
			result = result * 3
		AttackType.POUND:
			result = result * 2
		_:
			pass
	
	return result + damage_boosts[type]
