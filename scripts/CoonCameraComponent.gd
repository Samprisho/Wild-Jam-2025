extends SpringArm3D
class_name CoonCameraComponent

@export var coonCam: Camera3D
@export var coonBody: Coon

@onready var targetNode: Node3D = $SpringTarget

func _process(delta):
	if ClientControls.paused:
		return

	var mouseVel = -Input.get_last_mouse_velocity()


	rotation_degrees.x += mouseVel.y * ClientSettings.mouseSensivityY * delta

	rotation_degrees.x = clamp(rotation_degrees.x, -80, 80)

	coonBody.rotation_degrees.y += mouseVel.x * ClientSettings.mouseSensivityX * delta

	coonCam.rotation_degrees.x = rotation_degrees.x
	coonCam.rotation_degrees.y = coonBody.rotation_degrees.y

	coonCam.position = targetNode.global_position
