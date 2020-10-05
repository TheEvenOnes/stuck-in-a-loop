extends Spatial
class_name Task

func on_start() -> void:
	pass

func on_end() -> void:
	pass

func get_drone() -> Drone:
	return get_node('../../../') as Drone

func get_task_owner() -> Position3D:
	return get_node('../../../') as Position3D

func update(_delta: float, _delta_attenuated: float, _patrol_path: Path) -> void:
	pass
