extends AnimationTree

@onready var state_machine : AnimationNodeStateMachinePlayback = get("parameters/playback")
@onready var puppet : CharacterBody3D = get_parent().get_parent()

var attacking := false

func _physics_process(_delta):
	var velocity = puppet.velocity
	
	handle_animations(velocity)

func handle_animations(velocity: Vector3):
	if attacking:
		attacking = false
		state_machine.travel("gun_attack")
	else:
		if velocity.length() >= 0.5:
			state_machine.travel("walk")
		else:
			state_machine.travel("idle")

func set_attacking():
	attacking = true
	pass
