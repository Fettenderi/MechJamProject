extends Node

var current_wave : int = 0
var current_sub_wave : int = 0

func _ready():
#	GameMachine.connect("enemies_all_dead", advance_waves)
	# start_tutorial
	pass

func _process(delta):
	advance_waves()

func advance_waves():
	if current_wave < 5:
		current_sub_wave += 1
		if current_sub_wave % (current_wave + 2):
			current_sub_wave = 0
			current_wave += 1
		print(current_wave, current_sub_wave)
