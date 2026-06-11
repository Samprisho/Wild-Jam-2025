extends Node

signal GameSaved

var playerMovement: CoonMovement
var saveFileDir: String = "user://savegame.save"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DebugKey"):
		save_current_state()
	
	if event.is_action_pressed("DebugKey2"):
		load_from_save_file()

func save_current_state():
	var save_file = FileAccess.open(saveFileDir, FileAccess.WRITE)
	
	var data: Dictionary = {}
	
	data["map"] = get_tree().current_scene.scene_file_path
	
	if playerMovement:
		var lastState = playerMovement.lastState as CoonMovement.CoonStateContainer
		
		data["playerMovement"] = {
			"statePosition#x": lastState.statePosition.x,
			"statePosition#y": lastState.statePosition.y,
			"statePosition#z": lastState.statePosition.z,
			"stateVelocity#x": lastState.stateVelocity.x,
			"stateVelocity#y": lastState.stateVelocity.y,
			"stateVelocity#z": lastState.stateVelocity.z,
			"rotation#x": playerMovement.body.rotation.x,
			"rotation#y": playerMovement.body.rotation.y,
			"rotation#z": playerMovement.body.rotation.z,
		}

	for tracker in TimeKeeper.trackedNodeStates:
		var nodeData = {}
		
		var time = tracker.timeStamp
		var state: NodeState = tracker.states.get(time) as NodeState
		
		for propKey in state.savedProps.keys():
			var propVal = state.savedProps.get(propKey)
			
			if propVal is Vector3:
				nodeData[propKey + "#x"] = propVal.x
				nodeData[propKey + "#y"] = propVal.y
				nodeData[propKey + "#z"] = propVal.z
			else:
				nodeData[propKey] = propVal
			
		data[tracker.owningNode.name] = nodeData
		
	save_file.store_line(JSON.stringify(data))
	print("Game saved!")
	print(data)
	save_file.close()
	
func load_from_save_file():
	var save_file = FileAccess.open(saveFileDir, FileAccess.READ)
	
	if not save_file:
		push_error("COULD NOT LOAD SAVE FILE")
		
		return
	
	var line = save_file.get_line()
	var parsed: Dictionary = JSON.parse_string(line)
	
	var currMap = get_tree().current_scene.scene_file_path		
	if currMap != parsed.get("map"):
		var ok = get_tree().change_scene_to_file(parsed.get("map"))
		
		# Wait for level to load
		# ....twice: https://github.com/godotengine/godot/issues/86286
		await get_tree().process_frame
		await get_tree().process_frame
		# oh well, I'm happy this works. Upgrading the engine would be too much
		# of a hassle anyway
		
	
	for nodeKey in parsed.keys():
		# Skip loading the map, we already took care of  it
		if nodeKey == "map":
			continue
		
		if nodeKey == "playerMovement":
			var moveData = parsed.get("playerMovement")
			if playerMovement:
				var statePos = Vector3(
					moveData.get("statePosition#x"),
					moveData.get("statePosition#y"),
					moveData.get("statePosition#z"),
				)
				
				var stateVel = Vector3(
					moveData.get("stateVelocity#x"),
					moveData.get("stateVelocity#y"),
					moveData.get("stateVelocity#z"),
				)
				
				var rot = Vector3(
					moveData.get("rotation#x"),
					moveData.get("rotation#y"),
					moveData.get("rotation#z"),
				)
				
				playerMovement.lastState.statePosition = statePos
				playerMovement.lastState.stateVelocity = stateVel
				playerMovement.body.rotation = rot
				continue
				
		# Now, we take care of nodes using nodeTracker!
		var foundNode = get_tree().current_scene.find_child(nodeKey)
		if foundNode:
			var nodeData = parsed.get(nodeKey) as Dictionary
			var tracker: NodeTracker = foundNode.call("get_node_tracker") as NodeTracker
			
			if !tracker:
				push_error("LOAD GAME: could not get " + foundNode + "'s tracker. Have you implemented get_node_tracker() for " + foundNode + "?")
				continue
			
			for prop in tracker.propsToTrack:
				var propType = typeof(foundNode.get(prop))
				
				match propType:
					TYPE_FLOAT:
						foundNode.set(prop, nodeData.get(prop))
					TYPE_VECTOR3:
						var parsedVector = Vector3(
							nodeData.get(prop+"#x"),
							nodeData.get(prop+"#y"),
							nodeData.get(prop+"#z")
						)
						foundNode.set(prop, parsedVector)
					
			tracker.on_restored.emit(tracker.owningNode, tracker.timeStamp)
