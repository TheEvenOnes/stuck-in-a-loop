extends Spatial

const ProjectileImpact = preload("res://scenes/game_objects/ProjectileImpact.tscn")

export var LIFE: float = 10.0
export var DAMAGE: float = 1.0
export var PROJECTILE_LATERAL_SPEED: float = 4.0

onready var life: float = LIFE
var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var gravity: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
		return

	$Sprite3D.scale = Vector3(1, 1, 1) * (0.5 + 0.25 * sin(life * 25.0))

	var overlapping_entities = $Area.get_overlapping_bodies()
	for body in overlapping_entities:
		if body.is_in_group('enemy') or body.is_in_group('environment'):
			if body.is_in_group('enemy'):
				body.take_damage(DAMAGE)
			var particles = get_tree().current_scene.get_node('Particles')
			var impact_anim = ProjectileImpact.instance()
			particles.add_child(impact_anim)
			impact_anim.global_transform.origin = global_transform.origin
			translation.y -= 10.0
			return

	velocity.y -= delta * gravity
	translation += velocity * delta

func set_target(from: Vector3, to: Vector3) -> void:
	global_transform.origin = from
	var local_to = to - from
	var d = local_to
	d.y = 0
	var l = d.length()

	var vx = PROJECTILE_LATERAL_SPEED
	var t = l / vx
	var y_peak = l * 0.25 + 0.5 * (local_to.y)
	var y_end = local_to.y - 0.5
	var y0 = 0.0
	var g = -4.0 * (y0 - 2.0 * y_peak + y_end) / (t * t)
	var vy = -(3.0 * y0 - 4.0 * y_peak + y_end) / t

	velocity = d.normalized() * vx
	velocity.y = vy

	gravity = g
