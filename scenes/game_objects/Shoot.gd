extends Task
class_name Shoot

const Projectile = preload("res://scenes/game_objects/Projectile.tscn")

export var COOLDOWN: float = 1.2
export var RANGE: float = 55.0

onready var cooldown: float = COOLDOWN
onready var sensors_collider: CollisionShape = $Area/DetectionRange
onready var sensors: Area = $Area


func _ready() -> void:
	sensors_collider.shape.radius = RANGE

func update(delta: float, delta_attenuated: float, _patrol_path: Path) -> void:
	var drone = get_drone()

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
		if closest_enemy == null:
			closest_enemy = body
			closest_distance = closest_enemy.global_transform.origin.distance_squared_to(global_transform.origin)
		else:
			var body_distance: float = body.global_transform.origin.distance_squared_to(global_transform.origin)
			if closest_distance > body_distance:
				closest_enemy = body
				closest_distance = body_distance

	if closest_enemy:
		var projectile = Projectile.instance()
		projectile.set_target(global_transform.origin, closest_enemy.global_transform.origin)
		get_tree().current_scene.get_node('Projectiles').add_child(projectile)
