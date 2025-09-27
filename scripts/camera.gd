extends Node
class_name CameraControls

## This component controls a given camera to rotate to mouse motion
##
##


@export var springArm: SpringArm3D
@export var targetNode: Node3D

## Controls how sensitive mouse motion is
@export var mouseSensitivity: float = 35
@export var sensitivityCurve: Curve
@export var followSpeed: float = 7
@export var rotSpeed: float = 15

var targetRot: Vector3 = Vector3()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	targetRot = springArm.global_rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var currRot = springArm.global_rotation
		
		var mouseMotion: InputEventMouseMotion = event
		var velocity = mouseMotion.velocity * -1

		var result = get_process_delta_time() * mouseSensitivity * (Vector2(
			sensitivityCurve.sample(abs(velocity.x)),
			sensitivityCurve.sample(abs(velocity.y))
		) * sign(velocity))
		
		springArm.global_rotate(Vector3.UP, result.x)
		targetRot = springArm.global_rotation
		springArm.global_rotation = currRot

func _process(delta: float) -> void:
	springArm.global_position = lerp(
		springArm.global_position,
		targetNode.global_position,
		delta * followSpeed
	)
	springArm.global_rotation = Vector3(
			lerp_angle(springArm.global_rotation.x, targetRot.x, delta * rotSpeed),
			lerp_angle(springArm.global_rotation.y, targetRot.y, delta * rotSpeed),
			lerp_angle(springArm.global_rotation.z, targetRot.z, delta * rotSpeed)
		)
