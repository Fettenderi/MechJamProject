extends CharacterBody3D

const MAX_SPEED = 7.0

const ACCELERATION = 40.0
const DECELERATION = 80.0

const JUMP_VELOCITY = 7.0
const MAX_JUMP_CHARGE = 200

const ROTATION_SPEED = 7.5

@onready var jump_cooldown := $JumpCooldown
@onready var area_attack := $Fixed/AreaAttack
@onready var normal_attack := $Rotating/NormalAttack
@onready var drill_attack := $Rotating/DrillAttack
@onready var hitbox := $Fixed/Hitbox
@onready var rotating := $Rotating

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var can_jump:= true
var previous_weapon := 0
var moving_elapsed := 0.0

func _ready():
	area_attack.stats = get_node("/root/PlayerStats")
	normal_attack.stats = get_node("/root/PlayerStats")
	drill_attack.stats = get_node("/root/PlayerStats")
	hitbox.stats = get_node("/root/PlayerStats")
	
	jump_cooldown.connect("timeout", jump_cooldown_ended)

func _physics_process(delta) -> void:
	
	# Add gravity or attack.
	if not is_on_floor():
		if Input.is_action_just_pressed("player_attack"):
			velocity.y = - JUMP_VELOCITY * PlayerStats.jump_charge / MAX_JUMP_CHARGE
			previous_weapon = PlayerStats.run_selected_weapons
			PlayerStats.run_selected_weapons = Stats.AttackType.POUND
		else:
			velocity.y -= gravity * delta
		PlayerStats.jump_charge -= 1
	else:
		if PlayerStats.run_selected_weapons == Stats.AttackType.POUND:
			PlayerStats.run_selected_weapons = previous_weapon
			PlayerStats.damage_boosts[Stats.AttackType.POUND] = pow(2, PlayerStats.jump_charge / float(MAX_JUMP_CHARGE)) * 1.3 - 1
			area_attack.start_attack()
			moving_elapsed = 0
			PlayerStats.jump_charge = 0
		elif Input.is_action_just_pressed("player_attack"):
			match PlayerStats.run_selected_weapons:
				Stats.AttackType.NORMAL:
					normal_attack.start_attack()
				Stats.AttackType.DRILL:
					drill_attack.start_attack()
		elif Input.is_action_just_pressed("player_switch_weapon"):
			PlayerStats.run_selected_weapons = (PlayerStats.run_selected_weapons + 1) % (len(PlayerStats.menu_selected_weapons))
	
	# Handle Jump.
#	Fare in modo che il salto si debba caricare, quando rilasciato in base a quanto è carico appena 
#	si fa il ground pound fa progressivamente più danno, da 5s in poi fa sempre lo stesso danno (inverse_lerp o remap?? clampato)
#

	if is_on_floor() and can_jump:
		if Input.is_action_just_pressed("player_jump"):
			PlayerStats.jump_charge = 0
		if Input.is_action_pressed("player_jump"):
			PlayerStats.jump_charge = clamp(PlayerStats.jump_charge + PlayerStats.jump_charge_speed, 0, MAX_JUMP_CHARGE)
		if Input.is_action_just_released("player_jump"):
			velocity.y = JUMP_VELOCITY * PlayerStats.jump_charge / MAX_JUMP_CHARGE
			jump_cooldown.start()
			can_jump = false

	# Handle Exit.
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
	
	
	# Handle Direction and Movement
	var input_dir = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not PlayerStats.run_selected_weapons == Stats.AttackType.POUND:
		update_rotating(delta, direction)
		if is_on_floor():
			var saw_movement : float = saw_tooth(moving_elapsed) * clamp(1 - PlayerStats.jump_charge / MAX_JUMP_CHARGE, 0.2, 1.0)
			velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED * saw_movement, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED * saw_movement, ACCELERATION * delta)
			moving_elapsed += delta
		else:
			velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
		moving_elapsed = 0

	move_and_slide()

func saw_tooth(value: float) -> float:
	value *= 0.7
	return (pow(2.5, value - floor(value)) - 1) * 2 / 3

func jump_cooldown_ended() -> void:
	can_jump = true

func update_rotating(delta: float, direction: Vector3) -> void:
	var final_angle := acos(Vector3.RIGHT.dot(direction))
	if direction.z > 0:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, -final_angle, delta * ROTATION_SPEED)
	else:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, final_angle, delta * ROTATION_SPEED)
