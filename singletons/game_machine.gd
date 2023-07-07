
extends Node

func add_projectile(projectile: Node3D):
	get_node("Level/Projectiles").add_child(projectile)
