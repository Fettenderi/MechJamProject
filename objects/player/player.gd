extends CharacterBody3D

const ACCELERATION = 40.0
const DECELERATION = 80.0

const JUMP_VELOCITY = 7.0

const ROTATION_SPEED = 10.0

@export var camera : Camera3D

@onready var jump_cooldown := $JumpCooldown
@onready var energy_timer := $EnergyTimer
@onready var weapon_consumption_timer := $WeaponConsumptionTimer

@onready var area_attack := $Fixed/AreaAttack
@onready var normal_attack := $Rotating/NormalAttack
@onready var drill_attack := $Rotating/DrillAttack
@onready var gun := $Rotating/Gun
@onready var fotonic_cannon := $Rotating/FotonicCannon

@onready var hitbox := $Fixed/Hitbox
@onready var rotating := $Rotating
@onready var animation_tree := $Rotating/AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var cursor_image := preload("res://objects/player/cursor.png")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var can_jump := true
var signal_recieved := false
var can_attack := true
var can_remove_energy := true
var previous_weapon := 0
var moving_elapsed := 0.0
var attacking := false

var ray_origin := Vector3.ZERO
var ray_target := Vector3.ZERO

func _ready():
	Input.set_custom_mouse_cursor(cursor_image)
	
	area_attack.stats = get_node("/root/PlayerStats")
	normal_attack.stats = get_node("/root/PlayerStats")
	drill_attack.stats = get_node("/root/PlayerStats")
	fotonic_cannon.stats = get_node("/root/PlayerStats")
	hitbox.stats = get_node("/root/PlayerStats")
	gun.stats = get_node("/root/PlayerStats")
	
	PlayerStats.connect("dead", die)
	PlayerStats.connect("jump_fully_charged", jump_fully_charged_effect)
	GameMachine.connect("new_weapon_unlocked", available_weapons_changed)
	jump_cooldown.connect("timeout", jump_cooldown_ended)
	energy_timer.connect("timeout", energy_timer_ended)
	weapon_consumption_timer.connect("timeout", can_remove_energy_for_weapon)

func _physics_process(delta) -> void:
	# Add gravity or attack.
	var on_floor := is_on_floor()
	
	if not on_floor:
		handle_pound(delta)
	else:
		handle_attacks(delta)
	
	handle_jump(on_floor, delta)
	
	# Handle Direction and Movement
	var input_dir := Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var movement_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if PlayerStats.run_selected_weapons != Stats.AttackType.POUND and movement_direction:
		move(movement_direction, delta)
	else:
		stop_moving(delta)
		
	update_rotation()
	
	handle_animations(on_floor, attacking, PlayerStats.run_selected_weapons, movement_direction)
	
	attacking = false
	
	move_and_slide()


func handle_pound(delta: float):
	if Input.is_action_just_pressed("player_attack"):
		velocity.y = - JUMP_VELOCITY * PlayerStats.jump_charge / PlayerStats.max_jump_charge
		previous_weapon = PlayerStats.run_selected_weapons
		PlayerStats.run_selected_weapons = Stats.AttackType.POUND
	else:
		velocity.y -= gravity * delta
	PlayerStats.jump_charge = clamp(PlayerStats.jump_charge - 3 * PlayerStats.jump_charge_speed * delta, 0, PlayerStats.max_jump_charge)

func handle_attacks(delta: float):
	if PlayerStats.run_selected_weapons == Stats.AttackType.POUND:
		PlayerStats.run_selected_weapons = previous_weapon
		PlayerStats.damage_boosts[Stats.AttackType.POUND] = pow(2, PlayerStats.jump_charge / float(PlayerStats.max_jump_charge)) * 1.3 - 1
		area_attack.start_attack(PlayerStats.jump_charge / float(PlayerStats.max_jump_charge))
		moving_elapsed = 0
		PlayerStats.jump_charge = 0
		PlayerStats.drill_usage = 0
	elif Input.is_action_pressed("player_attack"):
		if can_attack:
			attacking = true
			match PlayerStats.run_selected_weapons:
				Stats.AttackType.NORMAL:
					normal_attack.start_attack()
					
				Stats.AttackType.DRILL:
					PlayerStats.drill_usage += delta
					if PlayerStats.drill_usage >= PlayerStats.min_drill_usage:
						handle_single_attack(drill_attack, Stats.AttackType.DRILL, PlayerStats.drill_usage)
						
				Stats.AttackType.GUN:
					handle_single_attack(gun, Stats.AttackType.GUN)
		else:
			if PlayerStats.energy >= 10:
				can_attack = true
	elif Input.is_action_just_released("player_attack") and PlayerStats.run_selected_weapons == Stats.AttackType.DRILL:
		PlayerStats.drill_usage = 0
	elif Input.is_action_just_pressed("player_switch_weapon"):
		PlayerStats.run_selected_weapons = (PlayerStats.run_selected_weapons + 1) % (len(PlayerStats.available_weapons))

func handle_single_attack(attack: Node3D, attack_type: Stats.AttackType, consumption_bonus : float = 0.0):
	if PlayerStats.energy > PlayerStats.weapon_energy_consumption[attack_type] + 10 + consumption_bonus:
		attack.start_attack()
		if can_remove_energy:
			can_remove_energy = false
			weapon_consumption_timer.start(1)
			PlayerStats.energy -= PlayerStats.weapon_energy_consumption[attack_type] + consumption_bonus
	else:
		can_attack = false

func handle_jump(on_floor: bool, delta: float):
	if on_floor and can_jump:
		if Input.is_action_just_pressed("player_jump"):
			PlayerStats.jump_charge = 0
		if Input.is_action_pressed("player_jump"):
			PlayerStats.jump_charge = clamp(PlayerStats.jump_charge + PlayerStats.jump_charge_speed * delta, 0, PlayerStats.max_jump_charge)
		if Input.is_action_just_released("player_jump"):
			velocity.y = JUMP_VELOCITY * PlayerStats.jump_charge / PlayerStats.max_jump_charge
			jump_cooldown.start()
			can_jump = false

func handle_animations(on_floor: bool, is_attacking: bool, weapon_state: Stats.AttackType, direction: Vector3):
	if is_attacking:
		match weapon_state:
			Stats.AttackType.NORMAL:
				state_machine.travel("normal_attack")
			Stats.AttackType.POUND:
				state_machine.travel("jump_land")
			Stats.AttackType.DRILL:
				if signal_recieved:
					signal_recieved = false
					state_machine.travel("drill_attack")
				else:
					state_machine.travel("drill_charge")
					
			Stats.AttackType.GUN:
				if signal_recieved:
					signal_recieved = false
					state_machine.travel("gun_attack")
			_:
				state_machine.travel("idle")
	else:
		if on_floor:
			if direction:
				state_machine.travel("walk")
			else:
				state_machine.travel("idle")
		else:
			if weapon_state == Stats.AttackType.POUND:
				state_machine.travel("fall")
			else:
				state_machine.travel("jump_land")


func move(direction : Vector3, delta: float):
	if is_on_floor():
		if PlayerStats.health <= PlayerStats.max_health / 4 or PlayerStats.energy <= PlayerStats.max_energy / 4:
			var saw_movement : float = clamp(1 - PlayerStats.jump_charge / PlayerStats.max_jump_charge, 0.2, 1.0) * saw_tooth(moving_elapsed)
			velocity_lerp(direction * PlayerStats.speed * saw_movement, ACCELERATION * delta)
			moving_elapsed += delta
		else:
			velocity_lerp(direction * PlayerStats.speed * 0.6 * clamp(1 - PlayerStats.jump_charge / PlayerStats.max_jump_charge, 0.2, 1.0), ACCELERATION * delta)
	else:
		velocity_lerp(direction * PlayerStats.speed * 0.6, ACCELERATION * delta)

func stop_moving(delta: float):
	velocity_lerp(Vector3.ZERO, DECELERATION * delta)
	moving_elapsed = 0


func velocity_lerp(end_velocity: Vector3, delta: float):
	velocity.x = move_toward(velocity.x, end_velocity.x, delta)
	velocity.z = move_toward(velocity.z, end_velocity.z, delta)

func saw_tooth(value: float) -> float:
	value *= 0.7
	return (pow(2.5, value - floor(value)) - 1) * 2 / 3

func update_rotation() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	
	var space_state = get_world_3d().direct_space_state
	
	var ray_parameters = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	
	var intersection = space_state.intersect_ray(ray_parameters)
	
	if not intersection.is_empty():
		var pos = intersection.position
		rotating.look_at(Vector3(pos.x, position.y, pos.z), Vector3.UP)


func energy_timer_ended() -> void:
	if PlayerStats.can_discharge:
		PlayerStats.energy = clamp(PlayerStats.energy - 1, 0, PlayerStats.max_energy)

func jump_cooldown_ended() -> void:
	can_jump = true

func jump_fully_charged_effect() -> void:
	area_attack.emit_particles()

func can_remove_energy_for_weapon():
	can_remove_energy = true

func set_signal_recieved():
	signal_recieved = true

func available_weapons_changed():
	if PlayerStats.available_weapons.has(Stats.AttackType.DRILL):
		$Rotating/PlayerMesh/Node2/mecha/leftUpperArm/leftLowerArm/leftHand/drill.set_deferred("visible", true) 

func die():
	queue_free()
