tool
extends Position3D
class_name EnemyExplosion


export(bool) var emitting setget set_emitting, get_emitting

export(float) var ttl = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$'Particles'.emitting = emitting
	$'Particles2'.emitting = emitting

func set_emitting(newval: bool) -> void:
	$'Particles'.emitting = newval
	$'Particles2'.emitting = newval

func get_emitting() -> bool:
	return $'Particles'.emitting or $'Particles2'.emitting

func _process(delta: float) -> void:
	ttl -= delta
	if ttl < 0:
		queue_free()
