extends Task
class_name Idle

var sleep_time: float = 5

signal wake

func update(delta: float, _delta_attenuated: float) -> void:
	get_task_owner().velocity = Vector3.ZERO
	sleep_time -= delta
	if sleep_time < 0:
		emit_signal("wake")
