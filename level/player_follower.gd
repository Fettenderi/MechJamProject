extends Node3D

@export var player: Node3D
@export_range(0.1, 10) var lerp_weight: float

func _physics_process(delta):
	position.x = lerp(position.x, player.position.x, lerp_weight)
	position.z = lerp(position.z, player.position.z, lerp_weight)
