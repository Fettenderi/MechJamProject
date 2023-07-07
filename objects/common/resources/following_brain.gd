extends Node3D

const MAX_SPEED = 2.0

const ACCELERATION = 40.0
const DECELERATION = 80.0

@export_range(0.0, 100.0) var too_close_distance : int

@onready var puppet : CharacterBody3D = get_parent()
var target : Area3D

@onready var follow_area := $FollowArea

func _ready():
	follow_area.connect("area_entered", target_entered_in_range)
	follow_area.connect("area_exited", target_exited_from_range)

func _physics_process(delta):
	if target and puppet.global_position.distance_to(target.global_position) > too_close_distance:
		var direction = puppet.global_position.direction_to(target.global_position)
		move(direction, delta)
	else:
		stop_moving(delta)
	puppet.move_and_slide()


func target_entered_in_range(area: Area3D):
	target = area

func target_exited_from_range(_area: Area3D):
	target = null


func move(direction : Vector3, delta: float):
	velocity_lerp(direction * MAX_SPEED, ACCELERATION * delta)

func stop_moving(delta: float):
	velocity_lerp(Vector3.ZERO, DECELERATION * delta)

func velocity_lerp(end_velocity: Vector3, delta: float):
	puppet.velocity.x = move_toward(puppet.velocity.x, end_velocity.x, delta)
	puppet.velocity.z = move_toward(puppet.velocity.z, end_velocity.z, delta)
