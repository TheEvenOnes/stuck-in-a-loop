extends Spatial

onready var particles: Particles = $Particles
onready var life: float = particles.lifetime * 2

func _ready() -> void:
	particles.emitting = true

func _process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
		return

