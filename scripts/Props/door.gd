extends PropActivator

@export var doorCollider: StaticBody3D
@export var doorMesh: MeshInstance3D

func _ready() -> void:
	super()
	
	prop_activate.connect(
		func():
			doorCollider.process_mode = Node.PROCESS_MODE_DISABLED
			doorMesh.hide()
	)
	
	prop_deactivate.connect(
		func():
			doorCollider.process_mode = Node.PROCESS_MODE_INHERIT
			doorMesh.show()
	)
