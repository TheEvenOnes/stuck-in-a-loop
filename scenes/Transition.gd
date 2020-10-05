extends CanvasLayer

export(String, FILE, "*.tscn") var next_scene_path

onready var _anim_player := $ColorRect/AnimationPlayer

#func _ready() -> void:
#	_anim_player.play("Fade")

func transition_to(_next_scene := next_scene_path) -> void:
	_anim_player.play("Fade")
	yield(_anim_player, "animation_finished")
	get_tree().change_scene(_next_scene)
	
	yield(get_tree().create_timer(0.5), "timeout")
	_anim_player.play_backwards("Fade")
	yield(_anim_player, "animation_finished")
