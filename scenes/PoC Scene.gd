extends Spatial

export var GEMS: float = 0.0
export var WAVE: int = 0
export var STATE: int = 0

enum SceneState {
	PREPARE = 0,
	IN_PROGRESS = 1,
	LOOSE = 2,
}

func _ready() -> void:
	set_gems(GEMS)

func get_gems() -> float:
	return GEMS

func set_gems(gems: float) -> void:
	GEMS = gems
	$Control/Label.text = String(int(gems))

func add_gems(gems: float) -> void:
	set_gems(GEMS + gems)

func remove_gems(gems: float) -> void:
	set_gems(GEMS - gems)

func get_current_wave() -> int:
	return WAVE

func next_wave() -> void:
	print_debug('start next wave')
	STATE = SceneState.IN_PROGRESS

func finish_wave() -> void:
	print_debug('prepare for next wave')
	STATE = SceneState.PREPARE

func loose() -> void:
	print_debug('loose - go to main menu')
	STATE = SceneState.LOOSE
