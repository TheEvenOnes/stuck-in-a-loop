extends Spatial
class_name LevelState

export var GEMS: float = 0.0
export var WAVE: int = 0
export var STATE: int = 0

export var SLOTS: int = 1

const DRONE = preload('res://scenes/game_objects/Drone.tscn')
const task_script = preload('res://scenes/game_objects/Task.gd')
onready var PATROL = { 'blueprint': preload('res://scenes/tasks/Patrol.tscn'), 'name': 'Patrol', 'path': $PathControl/Path.get_path() }
const SHOOT = { 'blueprint': preload('res://scenes/tasks/Shoot.tscn'), 'name': 'Shoot' }
const MINE = { 'blueprint': preload('res://scenes/tasks/Mine.tscn'), 'name': 'Mine' }

onready var drones: Array = [{
	'sprite': 'res://assets/drone_basicl.png',
	'tasks': [PATROL, SHOOT, MINE]
}]

enum SceneState {
	PREPARE = 0,
	IN_PROGRESS = 1,
	LOOSE = 2,
}

func _ready() -> void:
	set_gems(GEMS)
	next_wave()

func get_gems() -> float:
	return GEMS

func set_gems(gems: float) -> void:
	GEMS = gems
	$Control/HUD/Label.text = String(int(gems))

func add_gems(gems: float) -> void:
	set_gems(GEMS + gems)

func remove_gems(gems: float) -> void:
	set_gems(GEMS - gems)

func get_current_wave() -> int:
	return WAVE

func next_wave() -> void:
	print_debug('start next wave')
	STATE = SceneState.IN_PROGRESS
	launch_drones()

func launch_drones() -> void:
	for c in $Drones.get_children():
		$Drones.remove_child(c)
		c.free()

	var drone_idx: int = 0.0
	for drone in drones:
		var new_drone: Drone = DRONE.instance()
		new_drone.global_transform.origin.y += 0.2
		new_drone.PHASE_OFFSET = drone_idx * 1.0 / drones.size()
		new_drone.set_tasks(drone.tasks)
		$Drones.add_child(new_drone)
		drone_idx += 1

func launch_new_drone(drone) -> void:
	var new_drone: Drone = DRONE.instance()
	new_drone.global_transform.origin.y += 0.2
	new_drone.set_tasks(drone.tasks)
	$Drones.add_child(new_drone)

func finish_wave() -> void:
	print_debug('prepare for next wave')
	STATE = SceneState.PREPARE

func loose() -> void:
	print_debug('loose - go to main menu')
	STATE = SceneState.LOOSE

func get_next_drone_cost() -> float:
	return pow(2, drones.size()) *  100

func add_drone() -> Dictionary:
	var new_drone = {
		'sprite': 'res://assets/drone_basicl.png',
		'tasks': [PATROL, SHOOT, MINE]
	}
	drones.push_back(new_drone)
	return new_drone

func _process(_delta: float) -> void:
	$Control/HUD/NextIn.text = 'Next drone in: ' + String(int(get_next_drone_cost() - GEMS))
	if GEMS > get_next_drone_cost():
		remove_gems(get_next_drone_cost())
		var drone = add_drone()
		launch_new_drone(drone)







