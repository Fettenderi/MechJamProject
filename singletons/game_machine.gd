
extends Node

func add_projectile(projectile: PackedScene):
	get_node("Level/Projectiles").add_child(projectile.instantiate())
