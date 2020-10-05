extends Position3D
class_name Drone


export(int, 2, 6) var LOOP_SLOTS: int = 2
export var HEALTH: float = 10.0
export var SPEED: float = 2.0
export var SCHEDULER_RESOLUTION: float = 3.0
export var SCHEDULER_NOTIFY: float = 1.0
export var TASKS: Array = [] setget set_tasks, get_tasks
export var PHASE_OFFSET: float = 0.0

onready var cooldown: float = SCHEDULER_RESOLUTION
onready var current_task_index = 0
onready var tasks: Array = []

enum State {
	Rally = 0,
	Operate = 1,
}

var state = State.Rally


func set_tasks(tasks: Array) -> void:
	for task in $Root/Tasks.get_children():
		$Root/Tasks.remove_child(task)
		task.free()

	for task in tasks:
		if task.name == 'Patrol':
			var instance: Patrol = task.blueprint.instance()
			instance.PATH = task.path
			instance.PHASE_OFFSET = PHASE_OFFSET
			$Root/Tasks.add_child(instance)
		else:
			var instance = task.blueprint.instance()
			$Root/Tasks.add_child(instance)

func get_tasks() -> Array:
	return tasks

func _process(delta: float) -> void:
	if state == State.Rally:
		var path: Path = get_tree().get_current_scene().get_node('PathControl/Path')
		var l = path.get_curve().get_baked_length()
		var target: Vector3 = path.get_curve().interpolate_baked(PHASE_OFFSET * l, true) + Vector3(0.0, 0.2, 0.0)
		if target.distance_to(global_transform.origin) < 0.05:
			state = State.Operate
		global_transform.origin = global_transform.origin.linear_interpolate(target, 0.05)
		return

	var tasks = $Root/Tasks.get_children()
	if tasks.size() == 0:
		return

	cooldown -= delta
	if cooldown <= 0.0:
		cooldown = SCHEDULER_RESOLUTION
		tasks[current_task_index].on_end()
		current_task_index = (current_task_index + 1) % tasks.size()
		tasks[current_task_index].on_start()

	var delta_attenuated = delta
	if cooldown + SCHEDULER_NOTIFY > SCHEDULER_RESOLUTION:
		delta_attenuated *= clamp((1.0 - (cooldown + SCHEDULER_NOTIFY - SCHEDULER_RESOLUTION)) / SCHEDULER_NOTIFY, 0.0, 1.0)
	elif cooldown - SCHEDULER_NOTIFY <= 0.0:
		delta_attenuated *= clamp((1.0 - SCHEDULER_NOTIFY + cooldown) / SCHEDULER_NOTIFY, 0.0, 1.0)

	var task = tasks[current_task_index]
	task.update(delta, delta_attenuated)
