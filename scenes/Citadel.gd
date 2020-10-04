extends StaticBody
class_name Citadel

const Projectile = preload("res://scenes/game_objects/Projectile.tscn")
const ray_length = 1000

export var HEALTH: float = 10.0

onready var health: float = HEALTH

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released('left_click'):
		var position = get_viewport().get_mouse_position()
		var camera = $Camera
		var from = camera.project_ray_origin(position)
		var to = from + camera.project_ray_normal(position) * ray_length

		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to)

		var projectile = Projectile.instance()
		projectile.set_target($Turret.global_transform.origin, result.position)
		$ProjectileBucket.add_child(projectile)

func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0.0:
		emit_signal('citadel_destroyed')
