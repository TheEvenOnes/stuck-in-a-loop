extends KinematicBody
class_name Enemy

export var HEALTH: float = 4.0               # default health
export var AI_DECISION_TIMEOUT: float = 0.5  # how often are decisions made
export var NAV_MESH: NodePath                # a Navigation used for pathfinding
export var TARGET: NodePath                  # a Node used as target for pathfinding
export var SPEED: float = 3
export var AI_ENABLED: bool = true

onready var health: float = HEALTH
onready var ai_decision_timeout: float = AI_DECISION_TIMEOUT
var path: PoolVector3Array
var path_offset: float = 0
var dead_remove_ttl: float = INF
const EnemyExplosion = preload("res://scenes/game_objects/EnemyExplosion.tscn")

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

	if AI_ENABLED:
		ai_decision_timeout -= delta
		while ai_decision_timeout < 0:
			ai_decision()
			ai_decision_timeout += AI_DECISION_TIMEOUT

		navpath_move(delta)


func ai_decision() -> void:
	var target: Node = get_node(TARGET)
	if target == null:
		return

	var navmesh: Navigation = get_node(NAV_MESH) as Navigation
	assert(navmesh != null)

	var path_v3d: PoolVector3Array = navmesh.get_simple_path(
		navmesh.get_closest_point(self.global_transform.origin),
		target.global_transform.origin,
		true)
	path = path_v3d
	path_offset = 0


func navpath_move(delta: float) -> void:
	if path == null:
		return

	# Move along the path.
	path_offset += delta * SPEED

	# Find segment at which we arrived given the total distance traveled.
	var segment: Dictionary = find_segment_for_offset(path, path_offset)
	var found_segment_idx: int = segment["found_segment_idx"] as int
	var progress_in_segment: float = segment["progress_in_segment"] as float

	# If we found a relevant index, use the information on how far within the
	# segment we traveled, and position us appropriately.
	if found_segment_idx >= 0:
		var pt_a: Vector3 = path[found_segment_idx]
		var pt_b: Vector3 = path[found_segment_idx+1]
		var diff: Vector3 = pt_b - pt_a  # Total direction vector.
		diff *= progress_in_segment      # We need only 'path traveled so far'.
		var pt: Vector3 = pt_a + diff    # Find new location on the segment.
		self.global_transform.origin = pt

func find_segment_for_offset(path: PoolVector3Array, path_offset: float) -> Dictionary:
	# Move along the path until we get to the path_offset we look for.
	# Optimization idea: remember the last idx and remaining progress we
	# stopped at, then just advance by delta.
	var catchup: float = path_offset
	var progress_in_segment: float = 0.0
	var found: int = -1
	for idx in range(0, path.size()-1):
		var pt_a: Vector3 = path[idx]
		var pt_b: Vector3 = path[idx+1]

		var diff: Vector3 = (pt_b - pt_a)
		var segment_length: float = diff.length()
		if catchup - segment_length <= 0:
			found = idx
			progress_in_segment = catchup / segment_length
			break
		catchup -= segment_length
	return {
		"found_segment_idx": found,
		"progress_in_segment": progress_in_segment,
	}
