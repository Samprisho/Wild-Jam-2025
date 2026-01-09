extends CharacterBody3D
class_name Coon

@export var relatedBall: Ball
@export var camera: CoonCameraComponent
@export var embarkRange: float = 4

@onready var movement: CoonMovement = $CoonMovementComponent

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ToggleMode") and relatedBall and relatedBall.embarkTimer.is_stopped():
		var distance = relatedBall.global_position.distance_to(global_position)
		print("embarked: ", distance)
		if distance < embarkRange and not relatedBall.coonInside:
			relatedBall.switch_to_ball()


func switch_to_coon_mode() -> bool:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	camera.make_active()
	relatedBall.coonInside = false

	movement.lastState.statePosition = relatedBall.global_position + Vector3(0, relatedBall.size * 1.2, 0)
	global_rotation.y = relatedBall.springArm.global_rotation.y
	movement.lastState.stateVelocity = relatedBall.velocity + Vector3.UP * movement.jump_veloctiy
	
	print("coon mode!")
	
	return true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_airborne_state_entered() -> void:
	print("Now airborne") 


func _on_rising_state_entered() -> void:
	print("rising up")


func _on_grounded_state_entered() -> void:
	print("on my feet")
