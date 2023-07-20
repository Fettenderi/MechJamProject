extends Node3D

const MAX_SUBWAVES = 3
const MAX_TOTEM_HEIGHT = 11
const MIN_TOTEM_HEIGHT = 0.001
const MAX_MUTUAL_ENEMY_DISTANCE = 5
const MAX_BONUS_DISTANCE = 1
const MINUTE = 60

enum EnemyType {
	ALIEN,
	ROVER,
	MK1,
	SPACESHIP
}

@export var is_current_zone := false

@export var starting_ost := 1
@export var fighting_ost := 2
@export var id := 1

@export var base_enemy : EnemyType
@export var special_enemy : EnemyType

@onready var energy_supplier := $EnergySupplier
@onready var activation_particles := $ActivationParticles
@onready var zone_children := $ZoneChildren
@onready var zone_detector := $ZoneDetector
@onready var totem_percentage := $TotemPercentage
@onready var subwave_timer := $SubwaveTimer
@onready var corruption_timer := $CorruptionTimer

@onready var bonus := preload("res://objects/world/bonus.tscn")

@onready var enemies := [
	preload("res://objects/enemies/noob_alien.tscn"),
	preload("res://objects/enemies/rover.tscn"),
	preload("res://objects/enemies/mk1.tscn"),
	preload("res://objects/enemies/spaceship.tscn")
]

var is_second_phase := false

var zone_level := 0
var missing_subwaves := MAX_SUBWAVES
var once_cleared := false

var clear_percentage := 1.0
var max_child_count := 1

var next_corruption_timer := 11 * MINUTE

signal zone_corrupted
signal zone_cleared

func _ready():
	randomize()
	ZoneManager.connect("started_second_phase", start_second_phase)
	ZoneManager.connect("some_zone_was_corrupted", maybe_start_corrupting)
	subwave_timer.connect("timeout", advance_subwave)
	corruption_timer.connect("timeout", corrupt_zone)
	if is_current_zone:
		ZoneManager.corrupt_next(id)

func _process(delta):
	var current_children_count := zone_children.get_child_count()
	if current_children_count > max_child_count:
		max_child_count = current_children_count
	
	if zone_children.get_child_count() == 0 and missing_subwaves == 0 and not once_cleared:
		set_zone_cleared()

	totem_percentage.mesh.height = clamp(lerp(totem_percentage.mesh.height, MAX_TOTEM_HEIGHT * (1.0 - float(current_children_count) / max_child_count), delta * 20), MIN_TOTEM_HEIGHT, MAX_TOTEM_HEIGHT)

func advance_subwave():
	if missing_subwaves > 0:
		missing_subwaves -= 1
		if is_second_phase:
			spawn_wave()
		else:
			spawn_first()
		if missing_subwaves == 1:
			GameMachine.set_intensity(max(fighting_ost, GameMachine.get_intensity()))
		subwave_timer.start(rcc(missing_subwaves, MAX_SUBWAVES, 0, 60, 40))

func maybe_start_corrupting():
	if corruption_timer.wait_time == 0:
		next_corruption_timer = randi_range(4 * MINUTE, 6 * MINUTE)
	else:
		corruption_timer.start(randi_range(5 * MINUTE, 8 * MINUTE))

func start_corrupting():
	corruption_timer.start(30)

func corrupt_zone():
	emit_signal("zone_corrupted")
	Gui.add_warning("Zone " + str(id) + " has been invaded!")
	once_cleared = false
	if is_current_zone:
		PlayerStats.can_discharge = false
	if is_second_phase:
		GameMachine.set_intensity(clamp(GameMachine.get_intensity() + 1, 1, 6))
	else:
		GameMachine.set_intensity(starting_ost)
	energy_supplier.set_deferred("is_active", false)
	totem_percentage.mesh.height = MIN_TOTEM_HEIGHT
	advance_subwave()

func set_zone_cleared():
	once_cleared = true
	emit_signal("zone_cleared")
	Gui.add_notification("Zone Clear! Don't forget to check the area, we have some upgrades for you.")
	if is_second_phase:
		GameMachine.set_intensity(clamp(GameMachine.get_intensity() - 1, 1, 6))
	else:
		GameMachine.set_intensity(1)
	add_bonus()

func zone_looted():
	zone_level += 1
	activation_particles.set_deferred("set_emitting", true)
	is_current_zone = true
	energy_supplier.set_deferred("is_active", true)
	corruption_timer.start(next_corruption_timer)
	if not is_second_phase:
		ZoneManager.corrupt_next(id + 1)

func start_second_phase():
	corruption_timer.start(randi_range(1 * MINUTE, 4 * MINUTE))
	is_second_phase = true

func spawn_first():
	add_enemy(base_enemy, 4)
	add_enemy(special_enemy, rcc(missing_subwaves, MAX_SUBWAVES, 0, 1, 2))

func spawn_wave():
	add_enemy(EnemyType.ALIEN, rcc(zone_level, 0, 15, 6, 30))
	add_enemy(EnemyType.ROVER, rcc(zone_level, 1, 15, 2, 15))
	add_enemy(EnemyType.MK1, rcc(zone_level, 5, 15, 0, 10))
	add_enemy(EnemyType.SPACESHIP, rcc(zone_level, 8, 15, 0, 4))

func add_bonus():
	var bonus_scene_node := bonus.instantiate()
	bonus_scene_node.position = Vector3(randi_range(-MAX_BONUS_DISTANCE, MAX_BONUS_DISTANCE), 0, randi_range(-MAX_BONUS_DISTANCE, MAX_BONUS_DISTANCE))
	add_child(bonus_scene_node, true)
	bonus_scene_node.connect("choice_made", zone_looted)

func add_enemy(enemy_type: EnemyType, amount: int = 1):
	
	var enemy_scene : PackedScene = enemies[enemy_type]
	var height : float
	
	if enemy_type == EnemyType.SPACESHIP:
		height = 5
	else:
		height = 1.5
	
	if amount != 0:
		for _i in range(amount):
			var enemy_scene_node : CharacterBody3D = enemy_scene.instantiate()
			
			enemy_scene_node.position = Vector3(randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE), height, randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE))
			
			zone_children.add_child(enemy_scene_node)
			
			await get_tree().create_timer(0.1).timeout
 
func add_enemy_for_spaceship(enemy: Node3D):
	zone_children.add_child(enemy)

func rcc(value: float, istart: float, iend: float, ostart: float, oend: float) -> int:
	return ceil(clamp(remap(value, istart, iend, ostart, oend), ostart, oend))
