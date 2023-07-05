#extends Node
#
#@export var active := false
#
#@onready var current_scene : Node = get_node("World")
#
#func change_scene(next_scene : String) -> void:
#	current_scene = load("res://objects/scenes/" + next_scene + ".tscn").instance()
#	add_child(current_scene, true)
