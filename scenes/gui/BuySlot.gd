extends Button

func get_next_slot_cost(state: LevelState) -> float:
	return pow(2, state.SLOTS) *  100

func _process(_delta: float) -> void:
	var state: LevelState = get_tree().get_current_scene()

	if state.SLOTS == 5 || state.GEMS < get_next_slot_cost(state):
		disabled = true
	elif disabled:
		disabled = false

func _pressed() -> void:
	var state: LevelState = get_tree().get_current_scene()

	state.remove_gems(get_next_slot_cost(state))
	state.SLOTS += 1
