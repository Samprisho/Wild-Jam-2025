@tool
extends GoalCondition

@export var required_speed: float = 3:
	set(n):
		required_speed = n
		call_deferred("_reset_props")
@export_tool_button("Bruh", "Callable") var see_path_action = create_collision

@export_group("Nodes")
@export var collisionDisplay: MeshInstance3D
@export var detectionArea: Area3D
@export var detectionShape: CollisionShape3D
@export var displayText: Label3D
@export var start: Node3D
@export var end: Node3D

var lastSpeed: float = 0
var lastStart: Vector3 = Vector3.ZERO
var lastEnd: Vector3 = Vector3.ZERO

func _reset_props():
	displayText.text = str("%0.2f" % lastSpeed) + " / " + str(required_speed)

func _process(delta: float) -> void:
	
	if start.global_position != lastStart or end.global_position != lastEnd:
		create_collision()
		lastStart = start.global_position
		lastEnd = end.global_position

func create_collision():
	var convex: ConvexPolygonShape3D = ConvexPolygonShape3D.new() if detectionShape.shape == null else detectionShape.shape
	var arrayMesh: ArrayMesh = ArrayMesh.new() if collisionDisplay.mesh == null else collisionDisplay.mesh
	
	var pos1 = start.position
	var pos2 = end.position
	
	var points1: PackedVector3Array = [pos1 + Vector3(0, 1, 0), pos1 - Vector3(0, 1, 0)]
	var points2: PackedVector3Array = [pos2 + Vector3(0, 1, 0), pos2 - Vector3(0, 1, 0)]
	
	var all: PackedVector3Array = []
	all.append_array(points1)
	all.append_array(points2)
	
	convex.points = all
	detectionShape.shape = convex
	
	var meshSurface: PackedVector3Array = []
	meshSurface.append_array(points1)
	meshSurface.append(points2[1])
	meshSurface.append_array(points2)
	meshSurface.append(points1[0])
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = meshSurface
	
	arrayMesh.clear_surfaces()
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	collisionDisplay.mesh = arrayMesh

func _ready() -> void:
	detectionArea.body_entered.connect(_on_collision)

func _on_collision(body: Node3D):
	if body is RigidBody3D:
		var rigid = body as RigidBody3D
		displayText.text = rigid.linear_velocity.length() + " / " + str(required_speed)
		lastSpeed = rigid.linear_velocity.length()
	elif body is CharacterBody3D:
		var rigid = body as CharacterBody3D
		
		displayText.text = str("%0.2f" % rigid.velocity.length()) + " / " + str(required_speed)
		lastSpeed = rigid.velocity.length()
	
