extends Projectile

const ACCELERATION = 250.0

func _physics_process(delta):
	position += direction * ACCELERATION * delta * delta
