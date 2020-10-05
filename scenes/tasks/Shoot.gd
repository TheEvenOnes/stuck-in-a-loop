extends Task
class_name Shoot

const Projectile = preload("res://scenes/game_objects/Projectile.tscn")

export var COOLDOWN: float = 1.2
export var RANGE: float = 12.0

onready var cooldown: float = COOLDOWN
onready var sensors_collider: CollisionShape = $Area/DetectionRange
onready var sensors: Area = $Area


func _ready() -> void:
	sensors_collider.shape.radius = RANGE

func update(delta: float, _delta_attenuated: float) -> void:
	cooldown -= delta
	if cooldown <= 0.0:
		cooldown = COOLDOWN
		shoot()

func on_start() -> void:
	cooldown = COOLDOWN

func shoot() -> void:
	var enemies_in_range = sensors.get_overlapping_bodies()
	var closest_enemy: Spatial = null
	var closest_distance: float = 0
	for body in enemies_in_range:
		if body as Enemy == null:
			body = body.get_parent()
		if body as Enemy == null:
			print("WARNING: Skipping non-enemy found in in sensors.get_overlapping_bodies.")
			continue
		if closest_enemy == null:
			closest_enemy = body
			closest_distance = closest_enemy.global_transform.origin.distance_squared_to(global_transform.origin)
		else:
			var body_distance: float = body.global_transform.origin.distance_squared_to(global_transform.origin)
			if closest_distance > body_distance:
				closest_enemy = body
				closest_distance = body_distance

	if closest_enemy:
		var velocity = Vector3.ZERO
		if closest_enemy.get('velocity') != null:
			velocity = closest_enemy.velocity

		var projectile = Projectile.instance()
		projectile.set_target_with_lead(global_transform.origin, closest_enemy.global_transform.origin, velocity)
		get_tree().current_scene.get_node('Projectiles').add_child(projectile)
