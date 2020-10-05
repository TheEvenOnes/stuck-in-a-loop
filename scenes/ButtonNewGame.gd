extends Button

func _pressed():
	get_parent().visible = false
	Transition.transition_to("res://scenes/PoC Scene.tscn")
	#get_tree().change_scene("res://scenes/PoC Scene.tscn")
