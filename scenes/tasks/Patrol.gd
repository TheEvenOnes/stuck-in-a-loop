extends Task
class_name Patrol

export(NodePath) var PATH: NodePath
export var PHASE_OFFSET: float = 0.0

onready var elapsed: float = 0.0
var offset: float = 0.0

func update(delta: float, delta_attenuated: float) -> void:
	var path = get_node(PATH)
	var length: float = path.get_curve().get_baked_length()
	offset = length * PHASE_OFFSET
	var drone = get_drone()
	var speed = drone.SPEED

	elapsed += delta_attenuated * speed
	if offset + elapsed > length:
		elapsed -= length

	var sampled_position = path.get_curve().interpolate_baked(offset + elapsed, true)

	drone.translation.x = sampled_position.x
	drone.translation.z = sampled_position.z
