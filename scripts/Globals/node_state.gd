class_name NodeState

var timestamp = TimeKeeper.timestamp
var ownerNode: Node
var savedProps: Dictionary[StringName, Variant]

func _init(
	owner: Node,
) -> void:
	self.ownerNode = owner
	

func add_prop(propName: StringName, value: Variant):
	savedProps[propName] = value

func restore():
	for propName in savedProps.keys():
		ownerNode.set(propName, savedProps.get(propName))
		
