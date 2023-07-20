class_name Choice

extends Area3D

@export var title : String
@export var description : String

@onready var particles := $Particles
@onready var mesh : Node3D = $Mesh
@onready var shape := $CollisionShape3D
@onready var navigate_sfx := $NavigateSfx
@onready var select_sfx := $SelectSfx

signal was_chosen

var time := 0.0
var id := 0
var is_being_selected := false
var once_selected := false

func _ready():
	connect("area_entered", area_entered)
	connect("area_exited", area_exited)

func _process(delta):
	time += delta
	mesh.rotation.y = time
	
	if is_being_selected:
		if not once_selected:
			navigate_sfx.play()
			once_selected = true
		mesh.scale = lerp(mesh.scale, Vector3(1.7, 1.7, 1.7), delta * 10)
		mesh.position.y = 1.2
		if Input.is_action_just_pressed("interaction"):
			select_sfx.play()
			choice_made()
			ZoneManager.upgrades.remove_at(id)
			particles.call_deferred("set_emitting", true)
			shape.set_deferred("disabled", true)
			await get_tree().create_timer(0.4).timeout
			emit_signal("was_chosen")
	else:
		navigate_sfx.stop()
		once_selected = false
		mesh.position.y = (sin(time) + 0.5) * 0.5
		mesh.scale = lerp(mesh.scale, Vector3(1, 1, 1), delta * 10)

func area_entered(_area: Area3D = null):
	Gui.show_interaction_prompt(title, description)
	is_being_selected = true

func area_exited(_area: Area3D = null):
	Gui.hide_interaction_prompt()
	is_being_selected = false

func choice_made():
	pass
