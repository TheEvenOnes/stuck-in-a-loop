extends Sprite3D

var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	translation.y = 2.0 + sin(elapsed) * 1.0
