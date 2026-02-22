@tool
extends PropActivator
class_name JumpPad

##
## This is a jump pad! 
##
## The jump pad will propel whatever lands on it towards the [member launchDirectionNode]

@export var detactionArea: Area3D
@export var launchDirectionNode: Marker3D
@export var mesh: MeshInstance3D

@export_category("Launch properties")
@export var jumpPadPower: float = 13
@export var velocityOverride: bool = true
@export_category("Simulate")
@export var simulationTime: float = 2
@export var simulationPath: Path3D
@export_tool_button("Bruh", "Callable") var see_path_action = _on_see_jump_path

var mat: StandardMaterial3D
var plrSceneForEditor: PackedScene

var oldPos: Vector3 = Vector3.ZERO
var oldRot: Vector3 = Vector3.ZERO
var oldAimPos: Vector3 = Vector3.ZERO

func _on_see_jump_path():
	var curve: Curve3D = Curve3D.new()
	var delta = 1.0 / ProjectSettings.get("physics/common/physics_ticks_per_second")
	var simulationFrames = int(simulationTime * ProjectSettings.get("physics/common/physics_ticks_per_second"))
	
	var velocity = global_position.direction_to(launchDirectionNode.global_position) * jumpPadPower
	var position = Vector3.ZERO
	var GRAVITY = ProjectSettings.get("physics/3d/default_gravity")
	
	for i in simulationFrames:
		velocity.y -= GRAVITY * delta
		position += velocity * delta
		curve.add_point(position)
	
	simulationPath.curve = curve
	simulationPath.global_position = global_position

func _ready() -> void:
	if Engine.is_editor_hint():
		plrSceneForEditor = preload("res://scenes/Characters/the_coon.tscn")
		return
	
	super()
	detactionArea.body_entered.connect(_on_body_detected)
	
	if mesh.material_override is StandardMaterial3D:
		mat = mesh.material_override
	
	prop_activate.connect(func ():
		mat.albedo_color = Color.SKY_BLUE
	)
	
	prop_deactivate.connect(func ():
		mat.albedo_color = Color.GRAY
	)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not global_position == oldPos \
		or not global_rotation == oldRot \
		or not oldAimPos == launchDirectionNode.global_position:
			_on_see_jump_path()
			oldPos = global_position
			oldRot = global_rotation
			oldAimPos = launchDirectionNode.global_position
	

func _on_body_detected(body: Node3D):
	if not fulfilled:
		print(name + " conditions unfulfilled")
		return
	
	if body is Coon:
		_launch_coon(body)
	
	print("Jumping ", body.name)

func _launch_coon(body: Coon):
		print("Coon detected")
		body.velocity.y = 0
		var result: Vector3 = Vector3.ZERO
		var direction = global_position.direction_to(launchDirectionNode.global_position)
		
		result = direction * jumpPadPower + body.velocity
		
		print(result)
		
		body.apply_impulse(result, velocityOverride)
