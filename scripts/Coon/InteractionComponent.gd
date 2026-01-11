extends Area3D
class_name InteractionComponent

## Enables nodes to interact with other nodes. [br] [br]
## This should be used for something like characters or other player-controllable
## nodes and objects like buttons that can be pressed

## Emitted by interacter. See [method InteractionComponent.interact]
signal interacted(interacter: InteractionComponent)

## Finds first [InteractionComponent] (Which inherits [Area3D]) within the area's [CollisionShape3D]s and
## emits its [signal InteractionComponent.interacted]
func interact():
	var areas: Array[Area3D] = get_overlapping_areas()
	
	for a in areas:
		if a is InteractionComponent:
			a.interacted.emit(self)
			break
	
