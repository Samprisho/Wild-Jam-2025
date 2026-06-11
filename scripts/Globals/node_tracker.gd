class_name NodeTracker

var timeStamp: int
var owningNode: Node
var states: Dictionary[int, NodeState]
var propsToTrack: Array[StringName]
var sizeLimit: int

signal on_restored(node: Node, time: int)

func _init(
	owner: Node,
	sizeLimit: int,
	trackProps: Array[StringName] = [],
) -> void:
	self.owningNode = owner
	self.propsToTrack = trackProps
	self.sizeLimit = sizeLimit

func update(timestamp: int) -> void:
	if is_queued_for_deletion() || owningNode == null:
		return
	
	self.timeStamp = timestamp
	var newState = NodeState.new(owningNode)

	for propName in propsToTrack:
		newState.add_prop(propName, owningNode.get(propName))
	
	states[timestamp] = newState

	if states.size() > sizeLimit:
		erase_last()

func erase_last():
	states.erase(TimeKeeper.timestamp - sizeLimit)

func restore_n_stamps_ago(n: int):
	if n > timeStamp:
		states[0].restore()
		on_restored.emit(owningNode, 0)
	else:
		states[timeStamp - n].restore()
		on_restored.emit(owningNode, timeStamp - n)
