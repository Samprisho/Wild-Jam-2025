@tool
extends RigidBody3D

enum EPrimitiveType {
	SPHERE = 0,
	CUBE,
	CYLINDER
}



var grabbed: bool = false
var grabber: Coon
var grabTimer: Timer

func _ready() -> void:
	grabTimer = $grabTimer
	
	var interaction: InteractionComponent = $InteractionComponent
	interaction.interacted.connect(
		func(interacter: InteractionComponent):
			
			if interacter.get_parent().get_parent() is Coon:
				if not grabbed and grabTimer.is_stopped():
					grabbed = true
					grabber = interacter.get_parent().get_parent()
					grabTimer.start()
					print("coon grabbed me")
				else:
					grabbed = false
					grabber = null
					grabTimer.start()
					print("Coon let go")
	)

func _physics_process(delta: float) -> void:
	if grabbed and grabber:
		var targetPos = grabber.camera.coonCam.global_position + (-grabber.camera.global_basis.z * (size * 4))
		
		if grabber.camera.coonCam.global_position.distance_to(position) > 2.2:
			let_go()
			return
		
		linear_velocity = (targetPos - position) * 30
		look_at(grabber.camera.coonCam.global_position)

func let_go():
	grabbed = false
	grabber = null
	linear_velocity = Vector3.ZERO
	print("Coon let go")

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
	call_deferred("_reset_properties")

func _reset_properties():
	match primitive:
		EPrimitiveType.SPHERE:
			shape = SphereShape3D.new()
			mesh = SphereMesh.new()
			mesh.radial_segments = 10
			mesh.rings = 5
			
			mesh.radius = size
			mesh.height = size*2
			
			shape.radius = size*2.5
			
			
		EPrimitiveType.CUBE:
			shape = BoxShape3D.new()
			mesh = BoxMesh.new()
			
			shape.size = Vector3(size, size, size) * 2.5
			mesh.size = Vector3(size, size, size)
		EPrimitiveType.CYLINDER:
			shape = CylinderShape3D.new()
			mesh = CylinderMesh.new()
			
	
	$CollisionShape3D.shape = shape
	$MeshInstance3D.mesh = mesh
	$InteractionComponent/CollisionShape3D.shape = shape


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		let_go()
