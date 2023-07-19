extends Node

@export var max_player_distance := 30
@export var max_mutual_distance := 5
@export var killed_enemies_for_health := 5

@export var health_pellet : PackedScene
@export var energy_pellet : PackedScene

@export_group("ShakeScreen")
@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0

@export var noise : FastNoiseLite
@export var noise_speed := 50.0

@export_group("FMod")
@export var enemies_per_intensity := 5.0
@export var bus_asset: BusAsset
@export_range(0.0, 1.0) var volume: float = 1.0
@onready var intensity_delta := 1.0 / enemies_per_intensity

@onready var camera := get_node("Level/PlayerFollower/CameraPlayer")
@onready var minimap := get_node("Level/PlayerFollower/Minimap")
@onready var player := get_node("Level/Entities/Player")
@onready var music := $AllMusic
@onready var player_died_controller := $PlayerDiedController
@onready var low_battery_controller := $LowBatteryController

@onready var sound_test_emitter := $SoundTestEmitter
@onready var sound_test_controller := $SoundTestController

@onready var initial_rotation : Vector3 = camera.rotation_degrees

var bus: Bus
var trauma := 0.0
var time := 0.0
var is_screen_shaking := false
var enemy_count := 0
var enemy_for_health := killed_enemies_for_health
var previous_energy := PlayerStats.max_energy

signal new_weapon_unlocked
signal enemies_diminuished(value)
signal enemies_all_dead

func _ready():
	randomize()
	
	PlayerStats.connect("kills_changed", update_enemy_count)
	PlayerStats.connect("energy_changed", energy_changed)
	PlayerStats.connect("dead", player_died)
	
	bus = FMODStudioModule.get_studio_system().get_bus(bus_asset.path)
	bus.set_volume(volume)

func _physics_process(delta):
	
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
		

	if Input.is_action_just_pressed("debug_button"):
		if sound_test_controller.value == 0:
			sound_test_controller.value = 1
			sound_test_emitter.play()
		else:
			sound_test_controller.value = 0
			sound_test_emitter.stop()

	if Input.is_action_just_pressed("debug_button_1"):
#		WaveManager.advance_waves()
		pass
	
	if is_screen_shaking:
		screen_shake(delta)


func add_prop(prop: Node3D):
	get_node("Level/Props").add_child(prop)

func add_prop_at_random_location(prop_scene: PackedScene):
	var prop_scene_node : Node3D = prop_scene.instantiate()
	
	prop_scene_node.position = Vector3(randi_range(-max_player_distance, max_player_distance), 1, randi_range(-max_player_distance, max_player_distance)) + Vector3(player.global_position.x, 0, player.global_position.z)
	
	get_node("Level/Props").add_child(prop_scene_node)

func energy_changed(new_energy):
	low_battery_controller.value = clamp(remap(new_energy, 2, PlayerStats.max_energy / 4, 1.0, 0.0), 0.0, 0.8)
	low_battery_controller.trigger()

func player_died():
	player_died_controller.value = float((int(player_died_controller.value) + 1) % 2)
	player_died_controller.trigger()

func update_enemy_count(_value):
	enemy_for_health -= 1
	if enemy_for_health <= 0:
		enemy_for_health = killed_enemies_for_health
		if randf_range(0.0, 1.0) >= 0.5:
			add_prop_at_random_location(health_pellet)
		else:
			add_prop_at_random_location(energy_pellet)

func screen_shake(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	
	if trauma <= 0:
		is_screen_shaking = false

func add_trauma(trauma_amount : float):
	is_screen_shaking = true
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

@warning_ignore("shadowed_global_identifier")
func get_noise_from_seed(seed : int) -> float:
	noise.seed = seed
	return noise.get_noise_1d(time * noise_speed)


# Sblocca DRILL

#		PlayerStats.available_weapons.append(Stats.AttackType.DRILL)
#		emit_signal("new_weapon_unlocked")


# Aumenta e diminusici volume

#	if Input.is_action_just_pressed("debug_button"):
#		volume = clamp(volume + 0.1, 0.0, 1.0)
#		bus.set_volume(volume)
#
#	if Input.is_action_just_pressed("debug_button_1"):
#		volume = clamp(volume - 0.1, 0.0, 1.0)
#		bus.set_volume(volume)

