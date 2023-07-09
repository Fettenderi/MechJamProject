extends Brain

const ACCELERATION = 40.0
const DECELERATION = 80.0

const ROTATION_SPEED = 8.0

@export var rotating : Node3D

func far_behaviour(delta: float):
	stop_moving(delta)

func near_behaviour(delta: float):
	var direction = - puppet.global_position.direction_to(target.global_position)
#	update_rotation(direction, delta)
	move(direction, delta)

func out_of_range(delta: float):
	stop_moving(delta)

func always_behaviour(_delta: float):
	puppet.move_and_slide()


func move(direction : Vector3, delta: float):
	velocity_lerp(direction * (stats.speed + 1.2), ACCELERATION * delta * 2)

func stop_moving(delta: float):
	velocity_lerp(Vector3.ZERO, DECELERATION * delta)

func velocity_lerp(end_velocity: Vector3, delta: float):
	puppet.velocity.x = move_toward(puppet.velocity.x, end_velocity.x, delta)
	puppet.velocity.z = move_toward(puppet.velocity.z, end_velocity.z, delta)

func update_rotation(direction: Vector3, delta: float) -> void:
	var final_angle := acos(Vector3.RIGHT.dot(direction))
	if direction.z > 0:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, -final_angle, delta * ROTATION_SPEED)
	else:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, final_angle, delta * ROTATION_SPEED)
