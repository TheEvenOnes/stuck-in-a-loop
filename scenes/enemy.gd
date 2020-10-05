extends Position3D
class_name Enemy

export var HEALTH: float = 4.0               # default health
export var AI_DECISION_TIMEOUT: float = 0.5  # how often are decisions made
export var NAV_MESH: NodePath                # a Navigation used for pathfinding
export var TARGET: NodePath                  # a Node used as target for pathfinding
export var SPEED: float = 3

onready var health: float = HEALTH
onready var ai_decision_timeout: float = AI_DECISION_TIMEOUT
var dead_remove_ttl: float = INF
const EnemyExplosion = preload("res://scenes/game_objects/EnemyExplosion.tscn")
var velocity: Vector3 = Vector3.ZERO

onready var active_task: Task = $'Root/Tasks/Move'
var state: int = EnemyState.Idle

var rng = RandomNumberGenerator.new()

enum EnemyState {
	Idle = 0,
	Moving = 1,
	Shooting = 2,
}

func take_damage(damage: float) -> void:
	if !is_inf(dead_remove_ttl):
		return

	health -= damage
	if health <= 0.0:
		var enemy_explosion = EnemyExplosion.instance()
		get_tree().current_scene.get_node('Particles').add_child(enemy_explosion)
		enemy_explosion.global_transform.origin = self.global_transform.origin
		enemy_explosion.emitting = true
		dead_remove_ttl = 0.5


func _process(delta: float) -> void:
	if !is_inf(dead_remove_ttl):
		dead_remove_ttl -= delta
		if dead_remove_ttl < 0:
			queue_free()
		return

	ai_decision_timeout -= delta
	while ai_decision_timeout < 0:
		ai_decision()
		ai_decision_timeout += AI_DECISION_TIMEOUT

	active_task.update(delta, delta, null)


func ai_decision() -> void:
	match state:
		EnemyState.Moving:
			var move_task: Move = active_task as Move
			if move_task == null:
				# Not actually in the move task. Start moving.
				ai_decision_move()
				return

			if move_task.stamina <= 0:
				# Exhausted. Rest a bit.
				ai_decision_idle()
				return
			
			# Despite moving already, re-plan the move.
			ai_decision_move()

		EnemyState.Idle:
			var idle_task: Idle = active_task as Idle
			if idle_task == null:
				# Not actually in the idle task. Start idling.
				ai_decision_idle()
				return

			if idle_task.sleep_time <= 0:
				ai_decision_move()


func ai_decision_idle() -> void:
	# Start idling.
	active_task = $'Root/Tasks/Idle'
	active_task.sleep_time = 2
	state = EnemyState.Idle


func ai_decision_move() -> void:
	# Start moving.
	var target: Node = get_node(TARGET)
	if target == null:
		return

	var navmesh: Navigation = get_node(NAV_MESH) as Navigation
	assert(navmesh != null)

	active_task = $'Root/Tasks/Move'
	active_task.move(navmesh, target, SPEED)
	if state != EnemyState.Moving:
		# We are just starting to move, we were not already moving.
		active_task.stamina = 5
	state = EnemyState.Moving


func _on_Move_exhausted():
	ai_decision()


func _on_Idle_wake():
	ai_decision()
