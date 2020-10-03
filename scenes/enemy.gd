extends KinematicBody
class_name Enemy

export var HEALTH: float = 4.0

onready var health = HEALTH


func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0.0:
		# TODO: boom effect
		queue_free()
		return
