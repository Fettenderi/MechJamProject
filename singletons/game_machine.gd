extends Node

func add_projectile(projectile: Node3D):
	get_node("Level/Projectiles").add_child(projectile)

func _physics_process(_delta):
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("debug_button"):
		pass
