extends CharacterBody3D

@export var footsteps_sfx : EventAsset

@onready var footsteps_timer := $FootstepsTimer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_walking := false

func _ready():
	footsteps_timer.connect("timeout", do_footstep_sound)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	is_walking = velocity.length() >= 0.2
	if is_walking and footsteps_timer.time_left == 0:
		footsteps_timer.start(randf_range(2, 5))

func do_footstep_sound():
	if is_walking:
		RuntimeManager.play_one_shot_attached(footsteps_sfx, self)
		footsteps_timer.start(randf_range(2, 5))
