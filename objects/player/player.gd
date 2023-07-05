extends CharacterBody3D

const MAX_SPEED = 10.0
const ACCELERATION = 40.0
const DECELERATION = 80.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 7.5

@onready var jump_cooldown := $JumpCooldown
@onready var area_attack := $Fixed/AreaAttack
@onready var normal_attack := $Rotating/NormalAttack
@onready var hitbox := $Fixed/Hitbox
@onready var rotating := $Rotating

var can_jump:= true
var is_ground_pounding := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	area_attack.stats = get_node("/root/PlayerStats")
	normal_attack.stats = get_node("/root/PlayerStats")
	hitbox.stats = get_node("/root/PlayerStats")
	
	jump_cooldown.connect("timeout", jump_cooldown_ended)

func _physics_process(delta) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_just_pressed("player_attack"):
			velocity.y = - JUMP_VELOCITY
			is_ground_pounding = true
		else:
			velocity.y -= gravity * delta
	else:
		if is_ground_pounding:
			is_ground_pounding = false
			area_attack.start_attack()
		elif Input.is_action_just_pressed("player_attack"):
			normal_attack.start_attack()

	# Handle Jump.
#	Fare in modo che il salto si debba caricare, quando rilasciato in base a quanto è carico appena 
#	si fa il ground pound fa progressivamente più danno, da 5s in poi fa sempre lo stesso danno (inverse_lerp o remap?? clampato)
#
	if Input.is_action_just_pressed("player_jump") and is_on_floor() and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_cooldown.start()
		can_jump = false

	# Handle Exit.
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
	
	
	# Handle Direction and Movement
	var input_dir = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		update_rotating(delta, direction)
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)

	move_and_slide()

func jump_cooldown_ended() -> void:
	can_jump = true

func update_rotating(delta: float, direction: Vector3) -> void:
	var final_angle := acos(Vector3.RIGHT.dot(direction))
	if direction.z > 0:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, -final_angle, delta * ROTATION_SPEED)
	else:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, final_angle, delta * ROTATION_SPEED)
