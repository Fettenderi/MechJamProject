extends Brain

const ROTATION_SPEED = 8.0

@export var rotating : Node3D

@export var far_attack : Node3D
@export var near_attack : Node3D

func far_behaviour(_delta: float):
	if near_attack is Node3D:
		near_attack.end_attack()
	if far_attack is Node3D:
		far_attack.start_attack()

func near_behaviour(_delta: float):
	if near_attack is Node3D:
		near_attack.start_attack()
	if far_attack is Node3D:
		far_attack.end_attack()

func out_of_range(_delta: float):
	if near_attack is Node3D:
		near_attack.end_attack()
	if far_attack is Node3D:
		far_attack.end_attack()

func always_behaviour(_delta: float):
	pass
