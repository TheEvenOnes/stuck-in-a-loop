extends Task
class_name Mine

export var MINING_SPEED: float = 5.0

func update(_delta: float, delta_attenuated: float) -> void:
	mine(delta_attenuated)

func mine(delta_attenuated) -> void:
	get_tree().get_current_scene().add_gems(MINING_SPEED * delta_attenuated)

func on_start() -> void:
	$Particles.one_shot = false
	$Particles.emitting = true

func on_end() -> void:
	$Particles.one_shot = true
