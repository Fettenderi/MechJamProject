extends CharacterBody3D

const ACCELERATION = 40.0
const DECELERATION = 80.0

const JUMP_VELOCITY = 7.0
const MAX_JUMP_CHARGE = 200

const ROTATION_SPEED = 8.0

@onready var jump_cooldown := $JumpCooldown
@onready var energy_timer := $EnergyTimer

@onready var area_attack := $Fixed/AreaAttack
@onready var normal_attack := $Rotating/NormalAttack
@onready var drill_attack := $Rotating/DrillAttack
@onready var gun := $Rotating/Gun
@onready var drill_gun := $Rotating/DrillGun

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
	gun.stats = get_node("/root/PlayerStats")
	
	PlayerStats.connect("dead", die)
	PlayerStats.connect("jump_fully_charged", jump_fully_charged_effect)
	jump_cooldown.connect("timeout", jump_cooldown_ended)
	energy_timer.connect("timeout", energy_timer_ended)

func _physics_process(delta) -> void:
	# Add gravity or attack.
	if not is_on_floor():
		if Input.is_action_just_pressed("player_attack"):
			velocity.y = - JUMP_VELOCITY * PlayerStats.jump_charge / MAX_JUMP_CHARGE
			previous_weapon = PlayerStats.run_selected_weapons
			PlayerStats.run_selected_weapons = Stats.AttackType.POUND
		else:
			velocity.y -= gravity * delta
		PlayerStats.jump_charge = clamp(PlayerStats.jump_charge - 3 * PlayerStats.jump_charge_speed * delta, 0, MAX_JUMP_CHARGE)
	else:
		if PlayerStats.run_selected_weapons == Stats.AttackType.POUND:
			PlayerStats.run_selected_weapons = previous_weapon
			PlayerStats.damage_boosts[Stats.AttackType.POUND] = pow(2, PlayerStats.jump_charge / float(MAX_JUMP_CHARGE)) * 1.3 - 1
			area_attack.start_attack(PlayerStats.jump_charge / float(MAX_JUMP_CHARGE))
			moving_elapsed = 0
			PlayerStats.jump_charge = 0
		elif Input.is_action_pressed("player_attack"):
			match PlayerStats.run_selected_weapons:
				Stats.AttackType.NORMAL:
					normal_attack.start_attack()
				Stats.AttackType.DRILL:
					PlayerStats.drill_gun_charge += delta
					if PlayerStats.drill_gun_charge >= PlayerStats.min_drill_gun_charge:
						drill_gun.start_attack()
				Stats.AttackType.GUN:
					if PlayerStats.weapon_ammos[Stats.AttackType.GUN] > 0:
						gun.start_attack()
					else:
						GameMachine.add_trauma(1)
		elif Input.is_action_just_pressed("player_switch_weapon"):
			PlayerStats.run_selected_weapons = (PlayerStats.run_selected_weapons + 1) % (len(PlayerStats.menu_selected_weapons))
	
	if Input.is_action_just_released("player_attack"):
		if PlayerStats.drill_gun_charge >= PlayerStats.min_drill_gun_charge:
			drill_gun.start_attack()
		else:
			drill_attack.start_attack()
		PlayerStats.drill_gun_charge = 0
	
	# Handle Jump.
	
	if is_on_floor() and can_jump:
		if Input.is_action_just_pressed("player_jump"):
			PlayerStats.jump_charge = 0
		if Input.is_action_pressed("player_jump"):
			PlayerStats.jump_charge = clamp(PlayerStats.jump_charge + PlayerStats.jump_charge_speed * delta, 0, MAX_JUMP_CHARGE)
		if Input.is_action_just_released("player_jump"):
			velocity.y = JUMP_VELOCITY * PlayerStats.jump_charge / MAX_JUMP_CHARGE
			jump_cooldown.start()
			can_jump = false
	
	# Handle Direction and Movement
	var input_dir := Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var is_crouching := Input.is_action_pressed("player_crouch")
	var is_pounding := PlayerStats.run_selected_weapons == Stats.AttackType.POUND
	
	if is_pounding or is_crouching:
		if direction:
			update_rotation(direction, delta)
		stop_moving(delta)
	else:
		if direction:
			update_rotation(direction, delta)
			move(direction, delta)
		else:
			stop_moving(delta)
	
	move_and_slide()


func move(direction : Vector3, delta: float):
	if is_on_floor():
		var saw_movement : float = saw_tooth(moving_elapsed) * clamp(1 - PlayerStats.jump_charge / MAX_JUMP_CHARGE, 0.2, 1.0)
		velocity_lerp(direction * PlayerStats.speed * saw_movement, ACCELERATION * delta)
		moving_elapsed += delta
	else:
		velocity_lerp(direction * PlayerStats.speed, ACCELERATION * delta)

func stop_moving(delta: float):
	velocity_lerp(Vector3.ZERO, DECELERATION * delta)
	moving_elapsed = 0


func velocity_lerp(end_velocity: Vector3, delta: float):
	velocity.x = move_toward(velocity.x, end_velocity.x, delta)
	velocity.z = move_toward(velocity.z, end_velocity.z, delta)

func saw_tooth(value: float) -> float:
	value *= 0.7
	return (pow(2.5, value - floor(value)) - 1) * 2 / 3

func update_rotation(direction: Vector3, delta: float) -> void:
	var final_angle := acos(Vector3.RIGHT.dot(direction))
	if direction.z > 0:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, -final_angle, delta * ROTATION_SPEED)
	else:
		rotating.rotation.y = lerp_angle(rotating.rotation.y, final_angle, delta * ROTATION_SPEED)


func energy_timer_ended() -> void:
	if PlayerStats.can_discharge:
		PlayerStats.energy = clamp(PlayerStats.energy - 1, 0, PlayerStats.max_energy)

func jump_cooldown_ended() -> void:
	can_jump = true

func jump_fully_charged_effect() -> void:
	area_attack.emit_particles()

func die():
	queue_free()
