extends Node

@warning_ignore("unused_signal")
signal showPos(String)

func _ready():
	var hudScene : Node  = load("res://scenes/UI/hud.tscn").instantiate()
	get_tree().current_scene.add_child(hudScene)
	
