extends Node

@export var subwave_time := 10

@onready var intensity_controller := $IntensityController
@onready var subwave_advance_timer := $SubwaveAdvanceTimer

var current_wave : int = 0
var current_subwave : int = 0
var current_max_intensity : int = 0
var can_chill_out := false
var max_enemies_per_wave := 0

signal wave_changed(value)

func _ready():
	GameMachine.connect("enemies_all_dead", advance_waves)
	subwave_advance_timer.connect("timeout", advance_waves)
	GameMachine.connect("enemies_diminuished", update_intensity)
	# start_tutorial

func start_waves():
	subwave_advance_timer.start(subwave_time)

func advance_waves():
	GameMachine.add_spaceship()
	subwave_advance_timer.start(subwave_time)
	current_subwave += 1
	if current_subwave == current_wave:
		can_chill_out = true
		current_max_intensity = current_subwave
	elif current_subwave % (current_wave + 2) > current_wave:
		current_subwave = 0
		current_wave = current_wave + 1
		emit_signal("wave_changed", current_wave)
	intensity_controller.value = current_subwave
	intensity_controller.trigger()

func update_intensity(current_enemies: int):
	if can_chill_out:
		if current_enemies > max_enemies_per_wave:
			max_enemies_per_wave = current_enemies
		
		var new_intensity = ceil(remap(current_enemies, 1, max_enemies_per_wave, -1, current_wave))
		
		if new_intensity != intensity_controller.value:
			intensity_controller.value = new_intensity
			intensity_controller.trigger()
