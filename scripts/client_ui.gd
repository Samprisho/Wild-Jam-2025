extends Node

signal showPos(String)

func _ready():
	var hudScene : Node  = load("res://scenes/hud.tscn").instantiate()
	get_tree().current_scene.add_child(hudScene)
	