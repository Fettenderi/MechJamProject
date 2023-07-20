extends Label

@export var notification_text : String

@onready var despawn_timer := $DespawnTimer

func _ready():
	text = notification_text
	despawn_timer.connect("timeout", queue_free)
