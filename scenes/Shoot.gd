extends Task
class_name Shoot

export var COOLDOWN: float = 1.5

onready var cooldown: float = COOLDOWN

func update(delta: float, delta_attenuated: float) -> void:
	var drone = get_drone()

	cooldown -= delta
	if cooldown <= 0.0:
		cooldown = COOLDOWN
		print_debug('Pew!')
