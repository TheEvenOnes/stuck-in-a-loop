extends Spatial
class_name Task

func on_start() -> void:
	pass

func on_end() -> void:
	pass

func get_drone() -> Drone:
	return get_node('../../') as Drone

func update(delta: float, delta_attenuated: float) -> void:
	pass
