extends Brain

enum States {
	WAITING,
	MOVING,
	ROTATING
}

const CHANGE_STATE_PROBABILITY = 0.6

const ACCELERATION = 40.0
const DECELERATION = 80.0

const ROTATION_SPEED = 8.0

@export var rotating : Node3D
@export var wander_if_far := true
#@export var rotating_sfx : EventAsset = null

@onready var general_timer := $GeneralTimer

#var rotating_sfx : StudioEventEmitter3D

var state : States
var direction : Vector3
var is_rotating := false

func on_brain_start():
	randomize()
#	if get_node_or_null("RotatingSfx"):
#		rotating_sfx = $RotatingSfx
	general_timer.connect("timeout", maybe_change_state)
	direction = Vector3(randi_range(-1, 1), 0, randi_range(-1, 1)).normalized()
	general_timer.start(randf_range(2, 4))

func far_behaviour(delta: float):
	if wander_if_far:
		wander(delta)
	else:
		stop_moving(delta)

func near_behaviour(delta: float):
	if not wander_if_far:
		wander(delta)
	else:
		stop_moving(delta)

func out_of_range(delta: float):
	wander(delta)


func always_behaviour(_delta: float):
	puppet.move_and_slide()
	
#	if rotating_sfx and is_rotating:
#		RuntimeManager.play_one_shot_attached(footsteps_sfx, global_position)


func wander(delta: float):
	update_rotation(direction, delta)
	match state:
		States.WAITING:
			is_rotating = false
		States.MOVING:
			is_rotating = false
			move(direction, delta)
		States.ROTATING:
			is_rotating = true
			update_rotation(direction, delta)
			stop_moving(delta)

func maybe_change_state():
	if randf_range(0, 1) <= CHANGE_STATE_PROBABILITY:
		@warning_ignore("int_as_enum_without_cast")
		state = (state + 1) % 3
		direction = Vector3(randi_range(-1, 1), 0, randi_range(-1, 1)).normalized()
	general_timer.start(randf_range(2, 4))


@warning_ignore("shadowed_variable")
func move(direction : Vector3, delta: float):
	velocity_lerp(direction * stats.speed, ACCELERATION * delta)

func stop_moving(delta: float):
	velocity_lerp(Vector3.ZERO, DECELERATION * delta)

func velocity_lerp(end_velocity: Vector3, delta: float):
	puppet.velocity.x = move_toward(puppet.velocity.x, end_velocity.x, delta)
	puppet.velocity.z = move_toward(puppet.velocity.z, end_velocity.z, delta)

@warning_ignore("shadowed_variable")
func update_rotation(direction: Vector3, delta: float = 1) -> void:
#	if rotating_sfx:
#		pass
	
	var final_angle := acos(Vector3.RIGHT.dot(direction))
	if direction.z > 0:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, -final_angle, delta * ROTATION_SPEED)
	else:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, final_angle, delta * ROTATION_SPEED)
