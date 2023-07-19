class_name Choice

extends Area3D

@export var title : String
@export var description : String

@onready var particles := $Particles
@onready var mesh : Node3D = $Mesh

signal was_chosen

var time := 0.0

var is_being_selected := false

func _process(delta):
	time += delta
	mesh.rotation.y += time
	mesh.position.y = sin(time) + 0.5
	
	if is_being_selected:
		mesh.scale = lerp(mesh.scale, Vector3(1.5, 1.5, 1.5), delta * 10)
	else:
		mesh.scale = lerp(mesh.scale, Vector3(1, 1, 1), delta * 10)
	
	if Input.is_action_just_pressed("interaction"):
		choice_made()
		emit_signal("was_choice_made")
		particles.call_deferred("set_emitting", true)
		await get_tree().create_timer(3).timeout
		queue_free()

func area_entered(_area: Area3D = null):
	Gui.show_interaction_prompt(title, description)
	is_being_selected = true

func area_exited(_area: Area3D = null):
	Gui.hide_interaction_prompt()
	is_being_selected = false

func choice_made():
	pass
