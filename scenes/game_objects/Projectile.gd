extends Spatial

const ProjectileImpact = preload("res://scenes/game_objects/ProjectileImpact.tscn")

export var LIFE: float = 10.0
export var DAMAGE: float = 1.0
export var PROJECTILE_LATERAL_SPEED: float = 4.0

onready var life: float = LIFE
var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var gravity: float = 0.0
var dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Launch.play()
	$Launch.get_stream().set_loop(false)

func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
		return

	$Sprite3D.scale = Vector3(1, 1, 1) * (0.5 + 0.25 * sin(life * 25.0))

	if dead:
		# Already exploded; don't explode again.
		return

	# This script is shared for friendly and enemy projectiles.
	# Enemy projectiles hurt friendlies; friendly projectiles hurt enemies.
	var hurtable_group: String = 'enemy'
	if self.name == 'ProjectileEnemy':
		hurtable_group = 'friendly'

	var overlapping_entities = $Area.get_overlapping_bodies()

	var end_projectile: bool = false
	for body in overlapping_entities:
		if body.is_in_group(hurtable_group) or body.is_in_group('environment'):
			if body.is_in_group(hurtable_group) && body.get_parent().has_method('take_damage') != null:
				body.get_parent().take_damage(DAMAGE)
			end_projectile = true

	if end_projectile:
		var particles = get_tree().current_scene.get_node('Particles')
		var impact_anim = ProjectileImpact.instance()
		particles.add_child(impact_anim)
		impact_anim.global_transform.origin = global_transform.origin
		translation.y -= 10.0
		dead = true
		life = 0.5 # Matches duration of the boom sound
		$Boom.play()
		$Boom.get_stream().set_loop(false)
		return

	velocity.y -= delta * gravity
	translation += velocity * delta

func __solve_quadratic(a: float, b: float, c: float) -> Dictionary:
	var s0 = NAN
	var s1 = NAN

	var p: float
	var q: float
	var D: float

	# normal form: x^2 + px + q = 0
	p = b / (2 * a);
	q = c / a;

	D = p * p - q;

	if D == 0.0:
		s0 = -p;
		return { 'discriminant': 1, 's0': s0, 's1': s1 }
	elif D < 0:
		return { 'discriminant': 0, 's0': s0, 's1': s1 }
	else:
		var sqrt_D = sqrt(D)
		s0 =  sqrt_D - p
		s1 = -sqrt_D - p
		return { 'discriminant': 2, 's0': s0, 's1': s1 }

func lead_target(from: Vector3, target: Vector3, target_velocity: Vector3) -> Dictionary:
	var vx: float = PROJECTILE_LATERAL_SPEED
	var target_vel_xz: Vector3 = target_velocity
	target_vel_xz.y = 0
	var diff_xz = target - from
	diff_xz.y = 0

	var c0: float = target_vel_xz.dot(target_vel_xz) - vx * vx
	var c1: float = 2.0 * diff_xz.dot(target_vel_xz)
	var c2: float = diff_xz.dot(diff_xz)

	var result = __solve_quadratic(c0, c1, c2)

	var valid0: bool = result.discriminant > 0 && result.s0 > 0;
	var valid1: bool = result.discriminant > 1 && result.s1 > 0;

	var t: float
	if !valid0 && !valid1:
		return { 'valid': false }
	elif valid0 && valid1:
		t = min(result.s0, result.s1)
	else:
		t = result.s0 if valid0 else result.s1

	var impact_point = target + target_velocity * t

	return { 'valid': true, 'impact_point': impact_point }

func set_target(from: Vector3, to: Vector3) -> void:
	global_transform.origin = from
	var local_to = to - from
	var d = local_to
	d.y = 0
	var l = d.length()

	var vx = PROJECTILE_LATERAL_SPEED
	var t = l / vx
	var y_peak = l * 0.25 + 0.5 * (local_to.y)
	var y_end = local_to.y
	var y0 = 0.0
	var g = -4.0 * (y0 - 2.0 * y_peak + y_end) / (t * t)
	var vy = -(3.0 * y0 - 4.0 * y_peak + y_end) / t

	velocity = d.normalized() * vx
	velocity.y = vy

	gravity = g

func set_target_with_lead(from: Vector3, to: Vector3, velocity: Vector3) -> void:
	var res = lead_target(from, to, velocity)
	if res.valid:
		set_target(from, res.impact_point)
	else:
		print_debug('Impossible target')
