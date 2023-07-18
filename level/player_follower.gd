extends Node3D

@export var player: Node3D
@export_range(0.1, 100) var lerp_weight: float

@onready var minimap := $Minimap/MinimapCamera

func _ready():
	PlayerStats.connect("dead", die)

func _physics_process(delta : float) -> void:
	if player:
		position.x = lerp(position.x, player.position.x, lerp_weight * delta)
		position.z = lerp(position.z, player.position.z, lerp_weight * delta)
		
		minimap.position.x = lerp(minimap.position.x, player.position.x, lerp_weight * delta)
		minimap.position.z = lerp(minimap.position.z, player.position.z, lerp_weight * delta)

func die():
	player = null
