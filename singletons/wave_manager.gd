extends Node

@export var subwave_time := 10
@export var is_debug := false

@onready var intensity_controller := $IntensityController
@onready var subwave_advance_timer := $SubwaveAdvanceTimer

@onready var spaceship := preload("res://objects/enemies/spaceship.tscn")
@onready var noob_alien := preload("res://objects/enemies/noob_alien.tscn")
@onready var rover := preload("res://objects/enemies/rover.tscn")
@onready var mk1 := preload("res://objects/enemies/mk1.tscn")

var current_wave : int = 0
var current_subwave : int = 0
var subwave_count : int = 0
var current_max_intensity : int = 0
var can_chill_out := false
var max_enemies_per_wave := 0
var is_player_dead := false

signal wave_changed(value)

func _ready():
	if not is_debug:
		GameMachine.connect("enemies_all_dead", advance_waves)
		GameMachine.connect("enemies_diminuished", update_intensity)
		PlayerStats.connect("dead", update_deadiness)
		subwave_advance_timer.connect("timeout", advance_waves)
		subwave_advance_timer.start(subwave_time)
		spawn_wave()

func start_waves():
	if not is_debug:
		subwave_advance_timer.start(subwave_time)

func _physics_process(_delta):
	if is_debug:
		advance_waves()

func advance_waves():
	if current_wave <= 5:
		current_subwave += 1
		subwave_count += 1
		if current_subwave == current_wave:
			can_chill_out = true
			current_max_intensity = current_subwave
		elif current_subwave % (current_wave + 2) > current_wave:
			current_wave = current_wave + 1
			current_subwave = (current_wave - 2) * int(current_wave >= 3)
			emit_signal("wave_changed", current_wave)
		intensity_controller.value = current_subwave
		intensity_controller.trigger()
		if is_debug:
			print("Ondata: ", current_wave, ", Sotto ondata: ", current_subwave, ", Totale sotto ondate: ", subwave_count)
			pass
		else:
			spawn_wave()
			subwave_advance_timer.start(subwave_time)

func update_intensity(current_enemies: int):
	if can_chill_out:
		if current_enemies > max_enemies_per_wave:
			max_enemies_per_wave = current_enemies
		
		var new_intensity = ceil(remap(current_enemies, 1, max_enemies_per_wave, (current_wave - 2) * int(current_wave >= 3) - 1, current_wave))
		
		if new_intensity != intensity_controller.value:
			intensity_controller.value = new_intensity
			intensity_controller.trigger()

func spawn_wave():
	if not is_player_dead: # and current_subwave != 0:
		GameMachine.add_enemy(noob_alien, 5 * subwave_count)
		GameMachine.add_enemy(rover, 2 * subwave_count)
		GameMachine.add_enemy(mk1, ceil(clamp(remap(subwave_count, 8, 15, 1, 10), 0, 10)))
		GameMachine.add_enemy(spaceship, ceil(clamp(remap(subwave_count, 12, 15, 1, 4), 0, 4)), 5)
#	elif current_subwave == 0:
#		subwave_count -= 1

func update_deadiness():
	is_player_dead = true
