extends SpringArm3D
class_name CoonCameraComponent

@export var coonCam: Camera3D
@export var coonBody: Coon
@export var staticTarget:Node3D

@export var risingState :AtomicState

@onready var targetNode: Node3D = $SpringTarget

var offset: Vector3 = Vector3.ZERO
var allowYChange: bool = true
var yOffset: float = 0

func _ready() -> void:
	risingState.state_entered.connect(_on_rising)
	risingState.state_exited.connect(_on_rising_exit)

func add_offset(offset: Vector3):
	self.offset += offset

func jumped(atZ: float):
	pass

func dont_follow(time: float):
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouseVel = -event.relative
		rotation_degrees.x += mouseVel.y * ClientSettings.mouseSensivityY
		rotation_degrees.x = clamp(rotation_degrees.x, -80, 80)
		coonBody.rotation_degrees.y += mouseVel.x * ClientSettings.mouseSensivityX

func _process(delta):
	if ClientControls.paused:
		return
		
	yOffset = lerp(yOffset, coonBody.velocity.y * 0.03, delta * 20)
	offset.y = yOffset
	
	targetNode.position = staticTarget.position + offset
	
	coonCam.global_rotation_degrees.x = rotation_degrees.x
	coonCam.global_rotation_degrees.y = coonBody.rotation_degrees.y
	coonCam.global_position.x = targetNode.global_position.x
	coonCam.global_position.z = targetNode.global_position.z
	coonCam.global_position.y = targetNode.global_position.y

func make_active():
	coonCam.make_current()

func _on_rising():
	allowYChange = false

func _on_rising_exit():
	allowYChange = true
	
