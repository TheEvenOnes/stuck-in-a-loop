extends Spatial

const ProjectileImpact = preload("res://scenes/game_objects/ProjectileImpact.tscn")

export var LIFE: float = 10.0
export var DAMAGE: float = 1.0
export var GRAVITY: float = 4.0
export var HIT_TARGET_IN: float = 4

onready var life: float = LIFE
var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
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

	velocity.y -= delta * GRAVITY
	translation += velocity * delta

func set_target(from: Vector3, to: Vector3) -> void:
	translation = from
	var l = from.distance_to(to)
	var d = to - from
	var n = d.normalized()
	d.y = 0
	var speed = sqrt(d.x * d.x + d.z * d.z) / HIT_TARGET_IN
	velocity.x = n.x * speed
	velocity.z = n.z * speed
	velocity.y = GRAVITY * HIT_TARGET_IN / 2

