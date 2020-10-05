tool
extends Spatial

onready var path: Path = $Path
onready var geometry: ImmediateGeometry = $ImmediateGeometry

var SUBS = 128.0

func _process(_delta: float) -> void:
	if path == null:
		return

	var curve = path.get_curve()
	var l = curve.get_baked_length()
	if l <= 0.1:
		return

	var step = l / SUBS
	geometry.clear()


	var t = 0.0
	while t <= l:
		var start = curve.interpolate_baked(t, true)
		var end = curve.interpolate_baked(t + 0.2, true)
		var fwd = (end - start).normalized()
		var right = Vector3.UP.cross(fwd).normalized() * 0.2

		geometry.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		geometry.add_vertex(start + right - 0.05 * fwd)
		geometry.add_vertex(end)
		geometry.add_vertex(start)
		geometry.add_vertex(start - right - 0.05 * fwd)
		geometry.add_vertex(end)
		geometry.add_vertex(end)
		geometry.end()
		t += l * 0.1

	geometry.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	t = 0.0
	while t <= l:
		var from = curve.interpolate_baked(t, true)
		var tt = t + step - l if t + step > l else t + step
		var to = curve.interpolate_baked(tt, true)
		var direction = (to - from).normalized()
		var side = Vector3.UP.cross(direction) * 0.025
		geometry.add_vertex(from + side)
		geometry.add_vertex(from - side)
		t += step
	geometry.end()
