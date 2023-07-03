extends CharacterBody3D


const MAX_SPEED = 10.0
const ACCELERATION = 40.0
const DECELERATION = 80.0
const JUMP_VELOCITY = 4.5

@onready var jump_cooldown:= $JumpCooldown
var can_jump:= true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	jump_cooldown.connect("timeout", jump_cooldown_ended)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
#
#	Fare in modo che il salto si debba caricare, quando rilasciato in base a quanto è carico appena 
#	si fa il ground pound fa progressivamente più danno, da 5s in poi fa sempre lo stesso danno (inverse_lerp o remap?? clampato)
#
	if Input.is_action_just_pressed("player_jump") and is_on_floor() and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_cooldown.start()
		can_jump = false

	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)

	move_and_slide()

func jump_cooldown_ended():
	can_jump = true
