extends Node

var trackedNodeStates: Array[NodeTracker] = []
var timestamp: int = 0
var maxTrackerLength: int = 500

func _physics_process(_delta: float) -> void:
	if not trackedNodeStates.is_empty():
		for nodeTracker in trackedNodeStates:
			nodeTracker.update(timestamp)

	timestamp += 1

func register_node(node: Node, propsToTrack: Array[StringName]) -> NodeTracker:
	var newTracker: NodeTracker = NodeTracker.new(node, maxTrackerLength, propsToTrack)
	trackedNodeStates.append(newTracker)
	
	return newTracker
	
