extends Node
class_name CameraControls

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
	targetRot = springArm.rotation

func _process(delta: float) -> void:
	springArm.spring_length = lerp(springArm.spring_length, clamp(targetNode.linear_velocity.length(),springArmMinDistance + ball.size, springArmMaxDistance + ball.size), delta * springZoomSpeed)
	springArm.get_parent().global_position = lerp(
		springArm.get_parent().global_position,
		targetNode.global_position,
		delta * followSpeed
	)
	var curr: Vector3 = Vector3()
	var velocity = Input.get_last_mouse_velocity()* -1
	var result = delta * ClientSettings.ballMouseSensivity * velocity * 0.01
	curr = springArm.rotation_degrees
	
	springArm.rotation_degrees.x += result.y
	springArm.rotation_degrees.y += result.x
	
	targetRot = springArm.rotation_degrees
	
	springArm.rotation_degrees = lerp(
		curr,
		targetRot,
		delta * (rotSpeed + abs(curr.length() - targetRot.length()))
	)
	
	springArm.rotation_degrees = springArm.rotation_degrees.clamp(
		Vector3(-rotClamp, -9999999, 0),
		Vector3(rotClamp, 99999999, 0),
	)
