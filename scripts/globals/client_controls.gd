extends Node

signal clientGamePaused
signal clientGameUnpaused

var paused: bool = false

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("Pause"):
		paused = not paused

		if paused:
			clientGamePaused.emit()
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			clientGameUnpaused.emit()
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("Respawn"):
		get_tree().reload_current_scene()

	
