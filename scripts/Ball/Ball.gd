@tool
extends CharacterBody3D
class_name Ball

@export_category("Component Settings")
@export var ballOnlyMode: bool = false
@export var ownedCoon: Coon
@export var springArm: SpringArm3D
@export var camComponent: BallCameraComponent
@export var movementComponent: BallMovementComponent

@export var size: float = 1:
	set(newSize):
		size = newSize
		call_deferred("reset_collision_shape")

@onready var embarkTimer: Timer = Timer.new()
@onready var collider: CollisionShape3D = $CollisionShape3D

var collisionSphere: SphereShape3D
var initalFloorCastY: float

var coonInside: bool = false


func _ready() -> void:
	collisionSphere = collider.shape as SphereShape3D
	if Engine.is_editor_hint():
		return
		
	add_child(embarkTimer)
	embarkTimer.autostart = true
	embarkTimer.one_shot = true
	embarkTimer.wait_time = 1.5
	

	reset_collision_shape()
	
	if ballOnlyMode:
		if camComponent:
			camComponent.make_active()
	

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("ToggleMode"):
		if coonInside and embarkTimer.is_stopped():
			embarkTimer.start(0.5)
			ownedCoon.switch_to_coon_mode()
			


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	scale = Vector3(size, size, size)
	
	if velocity.length() > 0.01:
	
		var rot = Vector3.UP.cross(velocity.normalized())
		var speed = velocity.length() / size
		var angVel = speed * rot.normalized()
		
		if angVel.length() > 0:
			$MeshInstance3D.rotate(angVel.normalized(), angVel.length() * delta)

func reset_collision_shape():
	$MeshInstance3D.scale = Vector3(size, size, size)
	if collisionSphere:
		collisionSphere.radius = size * 0.5
	if movementComponent:
		movementComponent.jump_veloctiy = size * 2

func switch_to_ball() -> bool:
	ownedCoon.process_mode = Node.PROCESS_MODE_DISABLED
	coonInside = true
	ownedCoon.visible = false
	ownedCoon.position = Vector3.ZERO
	ownedCoon.velocity = Vector3.ZERO
	camComponent.make_active()
	embarkTimer.start(1.5)
	springArm.global_rotation.y = ownedCoon.camera.global_rotation.y
	
	return true
