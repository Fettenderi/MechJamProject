extends Control

@export var color_low: Color
@export var color_high: Color
@export var max_size: Vector2 = Vector2(200, 20)

@onready var health_bar := $HealthBar
@onready var energy_bar := $EnergyBar
@onready var weapon := $Weapon
@onready var kill_counter := $KillCounter
@onready var waves_counter := $WavesCounter
@onready var minimap_display := $Minimap

@onready var interaction_prompt := $InteractionPrompt
@onready var interaction_title := $InteractionTitle
@onready var interaction_description := $InteractionTitle/InteractionDescription

@onready var corruption_warning := $CorruptionWarning

@onready var minimap_viewport : Viewport = GameMachine.minimap


func remap_color(value: float, istart: float, istop: float, ostart: Color, ostop: Color) -> Color:
	return Color(remap(value, istart, istop, ostart.r, ostop.r), remap(value, istart, istop, ostart.g, ostop.g), remap(value, istart, istop, ostart.b, ostop.b))

func _ready():
	PlayerStats.connect("max_health_changed", update_max_health)
	PlayerStats.connect("max_energy_changed", update_max_energy)
	PlayerStats.connect("health_changed", update_health)
	PlayerStats.connect("energy_changed", update_energy)
	PlayerStats.connect("change_selected_weapon", update_selected_weapon)
	PlayerStats.connect("kills_changed", update_kill_counter)
	
	ZoneManager.connect("some_zone_was_corrupted", show_corruption_warning)
	
	minimap_display.texture = minimap_viewport.get_texture()
	kill_counter.text = "0"
	waves_counter.text = "0"
	health_bar.size = max_size
	health_bar.color = color_high

func update_health(new_health):
	health_bar.size.x = (float(new_health) / float(PlayerStats.max_health)) * float(max_size.x)
	
	@warning_ignore("integer_division")
	health_bar.color = remap_color(new_health, PlayerStats.max_health / 3, PlayerStats.max_health * 2 / 3, color_low, color_high)

func update_max_health(new_max_health):
	health_bar.size.x = (float(PlayerStats.health) / float(new_max_health)) * float(max_size.x)
	
	@warning_ignore("integer_division")
	health_bar.color = remap_color(PlayerStats.health, new_max_health / 3, new_max_health * 2 / 3, color_low, color_high)

func update_energy(new_energy):
	energy_bar.size.x = (float(new_energy) / float(PlayerStats.max_energy)) * float(max_size.x)

func update_max_energy(new_max_energy):
	energy_bar.size.x = (float(PlayerStats.energy) / float(new_max_energy)) * float(max_size.x)

func update_selected_weapon(new_selected_weapon):
	match new_selected_weapon:
		Stats.AttackType.NORMAL:
			weapon.text = "Normal"
		Stats.AttackType.DRILL:
			weapon.text = "Drill"
		Stats.AttackType.GUN:
			weapon.text = "Gun"
		Stats.AttackType.FOTONIC:
			weapon.text = "Fotonic"
		Stats.AttackType.POUND:
			weapon.text = "Pound"

func update_kill_counter(new_kills):
	kill_counter.text = str(new_kills)


func show_interaction_prompt(title: String, description: String):
	interaction_prompt.visible = true
	interaction_title.text = title
	interaction_title.visible = true
	interaction_description.text = description
	interaction_description.visible = true

func hide_interaction_prompt():
	interaction_prompt.visible = false
	interaction_title.visible = false
	interaction_description.visible = false

func show_corruption_warning():
	corruption_warning.visible = true
	await get_tree().create_timer(1).timeout
	corruption_warning.visible = false
	
