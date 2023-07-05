extends Node3D

@export var player: Node3D
@export_range(0.1, 100) var lerp_weight: float

func _physics_process(delta : float) -> void:
	position.x = lerp(position.x, player.position.x, lerp_weight * delta)
	position.z = lerp(position.z, player.position.z, lerp_weight * delta)
