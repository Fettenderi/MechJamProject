extends Area3D

@export_range(0.0, 3.0) var duration_time : float
@export var stats : Stats

@onready var shape := $Shape
@onready var duration_timer := $DurationTimer

func _ready() -> void:
	duration_timer.connect("timeout", end_attack)

func start_attack() -> void:
	duration_timer.start(duration_time)
	shape.set_deferred("disabled", false)

func end_attack() -> void:
	shape.set_deferred("disabled", true)

func get_stats() -> Stats:
	return stats
