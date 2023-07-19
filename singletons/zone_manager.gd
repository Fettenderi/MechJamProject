extends Node

var current_corrupted := 0
var is_second_phase := false

signal some_zone_was_corrupted
signal started_second_phase

func _ready():
	GameMachine.get_node("Level/Zones/Zone3").connect("zone_cleared", second_phase_started)

func second_phase_started():
	GameMachine.get_node("Level/Zones/Zone3").disconnect("zone_cleared", second_phase_started)
	emit_signal("started_second_phase")
	for i in range(3): # 0 1 2
		GameMachine.get_node("Level/Zones/Zone" + str(i + 1)).connect("zone_corrupted", some_zone_corrupted)
		GameMachine.get_node("Level/Zones/Zone" + str(i + 1)).connect("zone_cleared", some_zone_cleared)

func some_zone_corrupted():
	emit_signal("some_zone_was_corrupted")
	current_corrupted += 1
#	GameMachine.set_intensity(current_corrupted)

func some_zone_cleared():
	current_corrupted -= 1
#	GameMachine.set_intensity(current_corrupted)

func corrupt_next(id: int):
	GameMachine.get_node("Level/Zones/Zone" + str(id)).start_corrupting()
