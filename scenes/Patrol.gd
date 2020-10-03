extends Task
class_name Patrol

export(NodePath) var PATH: NodePath

onready var elapsed: float = 0.0

onready var path: Path = get_node(PATH)
onready var length: float = path.get_curve().get_baked_length()

func update(delta: float, delta_attenuated: float) -> void:
	var drone = get_drone()
	var speed = drone.SPEED

	elapsed += delta_attenuated * speed
	if elapsed > length:
		elapsed -= length

	var sampled_position = path.get_curve().interpolate_baked(elapsed, true)

	drone.translation.x = sampled_position.x
	drone.translation.z = sampled_position.z
