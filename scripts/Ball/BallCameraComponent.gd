extends Node
class_name BallCameraComponent

## This component controls a given camera to rotate to mouse motion
##
##

@export var springArm: SpringArm3D
@export var camera: Camera3D
@export var targetNode: Node3D
@export var ball: Ball
## Controls how sensitive mouse motion is
@export var sensitivityCurve: Curve
@export var followSpeed: float = 7
@export var rotSpeed: float = 40
@export var springZoomSpeed: float = 2
@export var springArmMaxDistance: float = 5
@export var springArmMinDistance: float = 2.7

var rotClamp = 85
var targetRot: Vector3 = Vector3()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if ClientControls.paused:
		return
	
	if event is InputEventMouseMotion:
		var curr: Vector3 = Vector3()
		var velocity = -event.relative
		var result = ClientSettings.ballMouseSensivity * velocity
		curr = springArm.rotation_degrees
		
		springArm.rotation_degrees.x += result.y
		
		springArm.rotation_degrees.x = clamp(springArm.rotation_degrees.x, -80 , 80)
		springArm.rotation_degrees.y += result.x
		

func make_active() -> void:
	camera.make_current()

func _process(delta: float) -> void:
	springArm.spring_length = lerp(springArm.spring_length, clamp(ball.velocity.length(),springArmMinDistance + ball.size, springArmMaxDistance + ball.size), delta * springZoomSpeed)
	springArm.get_parent().global_position = lerp(
		springArm.get_parent().global_position,
		targetNode.global_position,
		delta * followSpeed
	)
	
