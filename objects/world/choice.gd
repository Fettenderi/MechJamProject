class_name Choice

extends Area3D

@export var title : String
@export var description : String

@onready var particles := $Particles

signal was_choice_made

func _process(delta):
	if Input.is_action_just_pressed("interaction"):
		choice_made()
		emit_signal("was_choice_made")
		particles.call_deferred("set_emitting", true)
		await get_tree().create_timer(3).timeout
		queue_free()

func area_entered(_area: Area3D = null):
	Gui.show_interaction_prompt(title, description)

func area_exited(_area: Area3D = null):
	Gui.hide_interaction_prompt()

func choice_made():
	pass
