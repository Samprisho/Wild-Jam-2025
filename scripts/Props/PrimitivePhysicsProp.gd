@tool
extends RigidBody3D

enum EPrimitiveType {
	SPHERE = 0,
	CUBE,
	CYLINDER
}

@export var primitive: EPrimitiveType = EPrimitiveType.SPHERE:
	set(newPrim):
		primitive = newPrim
		call_deferred("_reset_properties")

@export var size: float = 1:
	set(newSize):
		size = newSize
		call_deferred("_reset_size")

var shape: Shape3D
var mesh: Mesh

func _reset_size():
	$CollisionShape3D.scale = Vector3(size,size,size)
	$MeshInstance3D.scale = Vector3(size,size,size)

func _reset_properties():
	match primitive:
		EPrimitiveType.SPHERE:
			shape = SphereShape3D.new()
			mesh = SphereMesh.new()
			mesh.radial_segments = 10
			mesh.rings = 5
		EPrimitiveType.CUBE:
			shape = BoxShape3D.new()
			mesh = BoxMesh.new()
		EPrimitiveType.CYLINDER:
			shape = CylinderShape3D.new()
			mesh = CylinderMesh.new()
	
	$CollisionShape3D.shape = shape
	$MeshInstance3D.mesh = mesh
