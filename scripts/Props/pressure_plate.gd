extends GoalCondition

@export var rigid: RigidBody3D
@export var mesh: MeshInstance3D

var mat: StandardMaterial3D

func _ready() -> void:
	mat = mesh.mesh.material
	

func _physics_process(delta: float) -> void:
	if not rigid:
		return

	if rigid.position.x > 0:
		if not fulfilled:
			complete()
			print("Pressure plate!")
			
	else:
		if fulfilled:
			revert()
			print("un pressure plate...")
	
	if mesh:
		if mat:
			if fulfilled:
				mat.albedo_color = Color(0,1,0)
			else:
				mat.albedo_color = Color(1,0,0)
			
	
	
