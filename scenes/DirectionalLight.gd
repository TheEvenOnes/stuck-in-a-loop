extends DirectionalLight

export var ANGULAR_SPEED: float = 0.05

var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed += delta

	light_energy = ((1.0 + sin(elapsed * ANGULAR_SPEED)) * 0.5) * 0.15
	transform = transform.rotated(Vector3.UP, elapsed * ANGULAR_SPEED / 360 )
