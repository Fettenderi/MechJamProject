extends Node3D

signal choice_made

func _ready():
	randomize()
	var choice : PackedScene
	await ZoneManager.ready
	for i in range(-1, 2, 1):
		choice = ZoneManager.upgrades.pick_random()
		var choice_node : Choice = choice.instantiate()
		choice_node.position = Vector3(i * 3, 0, 0)
		choice_node.id = ZoneManager.upgrades.find(choice)
		add_child(choice_node)
		choice_node.connect("was_chosen", choice_was_made)

func choice_was_made():
	emit_signal("choice_made")
	queue_free()
