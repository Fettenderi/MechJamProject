extends Sprite3D

@export var stats: Stats

@export var color_low: Color
@export var color_high: Color

@export var max_size: Vector2 = Vector2(200, 30)

@onready var health_color:= $HealthBarViewport/HealthColor
@onready var base:= $HealthBarViewport/BaseColor
@onready var health_bar_viewport:= $HealthBarViewport

func remap_color(value: float, istart: float, istop: float, ostart: Color, ostop: Color) -> Color:
	return Color(remap(value, istart, istop, ostart.r, ostop.r), remap(value, istart, istop, ostart.g, ostop.g), remap(value, istart, istop, ostart.b, ostop.b))

func _ready():
	stats.connect("health_changed", update_health_bar)
	
	base.size = max_size
	health_color.size = max_size
	health_color.color = color_high
	health_bar_viewport.size = max_size
	region_rect.size = max_size


func update_health_bar(new_health):
	health_color.size.x = (float(new_health) / float(stats.max_health)) * float(max_size.x)
	
	@warning_ignore("integer_division")
	health_color.color = remap_color(new_health, stats.max_health / 3, stats.max_health * 2 / 3, color_low, color_high)
