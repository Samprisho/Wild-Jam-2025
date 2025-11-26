extends CharacterBody3D
class_name raccoon

@export_category("Grounded")
@export var ground_acceleration: float = 2
@export var ground_friction: float = 10
@export var max_ground_speed: float = 20

@export_category("Airborne")
@export var air_acceleration: float = 2
@export var air_slowdown_factor: float = 2
@export var max_air_speed: float = 80

@export_category("Wallrun")
@export var wallrun_acceleration: float = 5
@export var wallrun_friction: float = 4
@export var max_wallrun_speed: float = 30


var stateChart: StateChart
var collisionMesh: CapsuleMesh

class CoonStateContainer:
	func _init(pos:Vector3, vel:Vector3) -> void:
		self.statePosition = pos
		self.stateVelocity = vel

	
	var statePosition: Vector3
	var stateVelocity: Vector3

class CoonInputContainer:
	func _init(axis, jumping, crouching) -> void:
		self.inputaxis = axis
		self.attemptingJump = jumping
		self.attemptingCrouch = crouching

	var inputaxis: Vector2
	var attemptingJump: bool
	var attemptingCrouch: bool


func _ready():
	stateChart = get_node("StateChart")
	

func _physics_process(_delta: float) -> void:
	var inputDir: Vector2 = Vector2(
		Input.get_axis("Backward", "Forward"),
		Input.get_axis("Left", "Right")
	)

	var jumping: bool = Input.is_action_pressed("Jump")

	var crouching: bool = Input.is_action_pressed("Ability 1")

	var input = CoonInputContainer.new(inputDir, jumping, crouching)
	var state = CoonStateContainer.new(position, velocity)

	if is_on_floor():
		ground_simulate(input, state)
	else:
		air_simulate(input, state)


func normalized_dir_from_axis(inputaxis: Vector2) -> Vector3:
	var dir := Vector3(0,0,0)

	dir += global_basis.z * inputaxis.x
	dir += global_basis.x * inputaxis.y

	dir = dir.normalized()

	return dir

func is_inputting_directions(input: CoonInputContainer) -> bool:
	var axis: Vector2 = input.inputaxis

	return axis.length() == 0

func air_simulate(input: CoonInputContainer, state: CoonStateContainer):


	move_and_slide()
	return CoonStateContainer.new(position, velocity)


func ground_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir = normalized_dir_from_axis(input.inputaxis)

	position = state.statePosition
	velocity = state.stateVelocity

	velocity += dir * ground_acceleration * get_physics_process_delta_time()

	if velocity.length() > max_ground_speed or not is_inputting_directions(input):
		velocity.move_toward(Vector3.ZERO, get_physics_process_delta_time() * ground_friction)

	move_and_slide()
	return CoonStateContainer.new(position, velocity)



func wallrun_simulate(input: CoonInputContainer, state: CoonStateContainer):


	move_and_slide()
	return CoonStateContainer.new(position, velocity)
