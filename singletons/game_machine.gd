extends Node

func add_prop(prop: Node3D):
	get_node("Level/Props").add_child(prop)

func _physics_process(_delta):
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("debug_button"):
		pass
