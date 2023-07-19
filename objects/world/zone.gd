extends Node3D

const MAX_SUBWAVES = 5
const MAX_TOTEM_HEIGHT = 10
const MIN_TOTEM_HEIGHT = 0.001
const MAX_MUTUAL_ENEMY_DISTANCE = 5
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

@export var base_enemy : EnemyType
@export var special_enemy : EnemyType

@onready var energy_supplier := $EnergySupplier
@onready var zone_children := $ZoneChildren
@onready var zone_bonus := $ZoneBonus
@onready var zone_detector := $ZoneDetector
@onready var totem_percentage := $TotemPercentage
@onready var subwave_timer := $SubwaveTimer
@onready var corruption_timer := $CorruptionTimer

@onready var intensity_controller := $IntensityController

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

var clear_percentage := 1.0
var max_child_count := 1

var next_corruption_timer := 1

signal zone_corrupted
signal zone_cleared

func _ready():
	randomize()
	ZoneManager.connect("started_second_phase", start_second_phase)
#	ZoneManager.connect("some_zone_was_corrupted", maybe_start_corrupting)
	zone_detector.connect("area_entered", update_clear_percentage)
	zone_detector.connect("area_exited", update_clear_percentage)
	subwave_timer.connect("timeout", advance_subwave)
	corruption_timer.connect("timeout", corrupt_zone)
	if is_current_zone:
		start_corrupting()

func update_clear_percentage(_area: Area3D = null):
	var current_children_count := zone_children.get_child_count()
	if current_children_count > max_child_count:
		max_child_count = current_children_count
	if current_children_count == 0 and is_second_phase:
		set_zone_cleared()
	totem_percentage.mesh.height = clamp(MAX_TOTEM_HEIGHT * (1.0 - float(current_children_count) / max_child_count), MIN_TOTEM_HEIGHT, MAX_TOTEM_HEIGHT)

func advance_subwave():
	if missing_subwaves > 0:
		missing_subwaves -= 1
		if is_second_phase:
			spawn_wave()
		else:
			spawn_first()
		subwave_timer.start()
	else:
		if is_second_phase:
			intensity_controller.value = max(fighting_ost, intensity_controller.value)
			intensity_controller.trigger()
		else:
			intensity_controller.value = max(fighting_ost, intensity_controller.value)
			intensity_controller.trigger()

func maybe_start_corrupting():
	if corruption_timer.wait_time == 0:
		next_corruption_timer = randi_range(4 * MINUTE, 6 * MINUTE)
	else:
		corruption_timer.start(randi_range(2 * MINUTE, 4 * MINUTE))

func start_corrupting():
	corruption_timer.start(30)

func corrupt_zone():
	emit_signal("zone_corrupted")
	if is_current_zone:
		PlayerStats.can_discharge = false
	if is_second_phase:
		intensity_controller.value = clamp(intensity_controller.value + 1, 1, 6)
		intensity_controller.trigger()
	else:
		intensity_controller.value = starting_ost
		intensity_controller.trigger()
	energy_supplier.is_active = false
	totem_percentage.mesh.height = MIN_TOTEM_HEIGHT
	advance_subwave()

func set_zone_cleared():
	emit_signal("zone_cleared")
	if is_second_phase:
		intensity_controller.value = clamp(intensity_controller.value - 1, 0, 6)
		intensity_controller.trigger()
	else:
		intensity_controller.value = 0
		intensity_controller.trigger()
	is_current_zone = true
	energy_supplier.is_active = true
	corruption_timer.start(next_corruption_timer)
	add_bonus()

func start_second_phase():
	corruption_timer.start(randi_range(1 * MINUTE, 4 * MINUTE))
	is_second_phase = true

func spawn_first():
	add_enemy(enemies[base_enemy], rcc(missing_subwaves, 5, 0, 5, 7))
	add_enemy(enemies[special_enemy], rcc(missing_subwaves, 5, 0, 1, 3))

func spawn_wave():
	add_enemy(enemies[EnemyType.ALIEN], rcc(zone_level, 0, 15, 5, 30))
	add_enemy(enemies[EnemyType.ROVER], rcc(zone_level, 1, 15, 1, 15))
	add_enemy(enemies[EnemyType.MK1], rcc(zone_level, 5, 15, 0, 10))
	add_enemy(enemies[EnemyType.SPACESHIP], rcc(zone_level, 8, 15, 0, 4), 5)

func add_bonus():
	var bonus_scene_node := bonus.instantiate()
	bonus_scene_node.position = global_position + Vector3(randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE), 1, randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE))
	zone_bonus.add_child(bonus_scene_node)

func add_enemy(enemy_scene: PackedScene, amount: int = 1, height: int = 1):
	if amount != 0:
		for _i in range(amount):
			var enemy_scene_node : CharacterBody3D = enemy_scene.instantiate()
			
			enemy_scene_node.position = Vector3(randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE), height, randi_range(-MAX_MUTUAL_ENEMY_DISTANCE, MAX_MUTUAL_ENEMY_DISTANCE))
			
			zone_children.add_child(enemy_scene_node)
			
			await get_tree().create_timer(0.1).timeout

func rcc(value: float, istart: float, iend: float, ostart: float, oend: float) -> int:
	return ceil(clamp(remap(value, istart, iend, ostart, oend), ostart, oend))
