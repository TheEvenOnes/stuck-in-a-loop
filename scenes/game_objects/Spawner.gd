extends Spatial
class_name Spawner

const dummy = preload("res://scenes/Dummy.tscn")

export(NodePath) var TARGET: NodePath
export(NodePath) var NAV_MESH: NodePath

export(int) var remaining_spawns: int = 10
export(float) var default_time_to_spawn: float = 10
export(float) var tts_nudge: float = 0.5

var time_to_spawn: float = 0
var first_spawn: bool = true

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_to_spawn -= delta
	while time_to_spawn <= 0:
		time_to_spawn += default_time_to_spawn + rng.randf_range(-tts_nudge, tts_nudge)
		if first_spawn:
			first_spawn = false
			continue
		if remaining_spawns <= 0:
			continue
		var enemy: Enemy = dummy.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
		get_tree().current_scene.get_node("Enemies").add_child(enemy)
		enemy.global_transform.origin = self.global_transform.origin
		enemy.NAV_MESH = get_node(NAV_MESH).get_path()
		enemy.TARGET = get_node(TARGET).get_path()
		remaining_spawns -= 1
