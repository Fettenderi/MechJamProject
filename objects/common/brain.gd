class_name Brain

extends Node3D

@export_range(0.0, 100.0) var switching_behaviour_distance : int
@export var stats : Stats

@onready var puppet : CharacterBody3D = get_parent().get_parent()
var target : Area3D

@onready var target_range_area := $TargetRangeArea

func _ready():
	target_range_area.connect("area_entered", target_entered_in_range)
	target_range_area.connect("area_exited", target_exited_from_range)
	on_brain_start()

func _physics_process(delta: float):
	if target:
		if puppet.global_position.distance_to(target.global_position) > switching_behaviour_distance:
			far_behaviour(delta)
		else:
			near_behaviour(delta)
	else:
		out_of_range(delta)
	always_behaviour(delta)

func on_brain_start():
	pass

func far_behaviour(_delta: float):
	pass

func near_behaviour(_delta: float):
	pass

func out_of_range(_delta: float):
	pass

func always_behaviour(_delta: float):
	pass


func target_entered_in_range(area: Area3D):
	target = area

func target_exited_from_range(_area: Area3D):
	target = null
