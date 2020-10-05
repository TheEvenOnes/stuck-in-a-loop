extends Task
class_name Move

var speed: float
var active_path: PoolVector3Array
var current_path_offset: float = 0
var stamina: float

signal exhausted

func move(nav_mesh: Navigation, new_target: Node, new_speed: float) -> void:
	var owner: Position3D = get_task_owner()
	assert(owner != null)
	var path: PoolVector3Array = nav_mesh.get_simple_path(
		nav_mesh.get_closest_point(owner.global_transform.origin),
		new_target.global_transform.origin,
		true)
	active_path = path
	current_path_offset = 0


# NOTE: Patrol path is unused, because this task specifically uses navmesh
# for movement.
func update(delta: float, _delta_attenuated: float, _patrol_path: Path) -> void:
	if delta == 0:
		return
	if active_path == null:
		return
	var owner: Position3D = get_task_owner()
	assert(owner != null)

	stamina -= delta
	if stamina < 0:
		emit_signal("exhausted")

	# Move along the path.
	current_path_offset += delta * speed

	# Find segment at which we arrived given the total distance traveled.
	var segment: Dictionary = find_segment_for_offset(active_path, current_path_offset)
	var found_segment_idx: int = segment["found_segment_idx"] as int
	var progress_in_segment: float = segment["progress_in_segment"] as float

	# If we found a relevant index, use the information on how far within the
	# segment we traveled, and position us appropriately.
	if found_segment_idx >= 0:
		var pt_a: Vector3 = active_path[found_segment_idx]
		var pt_b: Vector3 = active_path[found_segment_idx+1]
		var diff: Vector3 = pt_b - pt_a  # Total direction vector.
		diff *= progress_in_segment      # We need only 'path traveled so far'.
		var pt: Vector3 = pt_a + diff    # Find new location on the segment.
		owner.velocity = (pt - owner.global_transform.origin) / delta
		owner.global_transform.origin = pt
		current_path_offset += delta

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
