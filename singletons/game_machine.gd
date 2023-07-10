extends Node

@export var max_level_size = Vector2(100, 100)
@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise : FastNoiseLite
@export var noise_speed := 50.0

@onready var camera := get_node("Level/PlayerFollower/CameraPlayer")
@onready var event_emitter := $EventEmitter
@onready var player_died_controller := $PlayerDiedController
@onready var intensity_controller := $IntensityController
@onready var spaceship := preload("res://objects/enemies/spaceship.tscn")

@onready var initial_rotation : Vector3 = camera.rotation_degrees

var trauma := 0.0
var time := 0.0
var is_screen_shaking := false

func _ready():
	randomize()
	
	PlayerStats.connect("waves_changed", add_spaceship)
	PlayerStats.connect("dead", add_spaceship)
	add_spaceship()

func add_prop(prop: Node3D):
	get_node("Level/Props").add_child(prop)

func add_entity(entity: Node3D):
	get_node("Level/Entities").add_child(entity)

func add_spaceship(_value: int = 0):
	intensity_controller.value = float((int(intensity_controller.value) + 1) % 6)
	intensity_controller.trigger()
	var spaceship_node : CharacterBody3D = spaceship.instantiate()
	
	@warning_ignore("narrowing_conversion")
	spaceship_node.position = Vector3(randi_range(-max_level_size.x, max_level_size.x), 5, randi_range(-max_level_size.y, max_level_size.y))
	
	get_node("Level/Entities").add_child(spaceship_node)

func _physics_process(delta):
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("debug_button"):
		intensity_controller.value = float((int(intensity_controller.value) + 1) % 7)
		intensity_controller.trigger()
	
	if Input.is_action_just_pressed("debug_button_1"):
		player_died_controller.value = float((int(player_died_controller.value) + 1) % 2)
		player_died_controller.trigger()
	
	if is_screen_shaking:
		screen_shake(delta)

func player_died():
	player_died_controller.value = float((int(player_died_controller.value) + 1) % 2)
	player_died_controller.trigger()


func screen_shake(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
#	camera.rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
	
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




