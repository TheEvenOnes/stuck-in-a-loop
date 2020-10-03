extends KinematicBody
class_name Drone


export(int, 2, 6) var LOOP_SLOTS: int = 2
export var HEALTH: float = 10.0
export var SPEED: float = 2.0
export var SCHEDULER_RESOLUTION: float = 5.0
export var SCHEDULER_NOTIFY: float = 1.5

onready var cooldown: float = SCHEDULER_RESOLUTION
onready var current_task_index = 0
onready var tasks: Array = $Tasks.get_children()

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown <= 0.0:
		cooldown = SCHEDULER_RESOLUTION
		current_task_index = (current_task_index + 1) % 2

	var delta_attenuated = delta
	if cooldown + SCHEDULER_NOTIFY > SCHEDULER_RESOLUTION:
		delta_attenuated *= clamp((1.0 - (cooldown + SCHEDULER_NOTIFY - SCHEDULER_RESOLUTION)) / SCHEDULER_NOTIFY, 0.0, 1.0)
	elif cooldown - SCHEDULER_NOTIFY <= 0.0:
		delta_attenuated *= clamp((1.0 - SCHEDULER_NOTIFY + cooldown) / SCHEDULER_NOTIFY, 0.0, 1.0)

	var task = tasks[current_task_index]
	task.update(delta, delta_attenuated)
