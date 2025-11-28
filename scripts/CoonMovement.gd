extends Node
class_name CoonMovement

@export var body: Coon

@export_category("Grounded")
@export var ground_acceleration: float = 15
@export var ground_friction: float = 15
@export var max_ground_speed: float = 5

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
var ownedBall: Ball

var GRAVITY: float = ProjectSettings.get("physics/3d/default_gravity")

var active: bool = false

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
	pass
	

func _physics_process(_delta: float) -> void:
	var inputDir: Vector2 = Vector2(
		# Remember, -Z is forward, and Z is backward
		Input.get_axis("Forward", "Backward"),
		Input.get_axis("Left", "Right")
	)

	var jumping: bool = Input.is_action_pressed("Jump")

	var crouching: bool = Input.is_action_pressed("Ability 1")

	var input = CoonInputContainer.new(inputDir, jumping, crouching)
	var state = CoonStateContainer.new(body.position, body.velocity)

	if body.is_on_floor():
		ground_simulate(input, state)
	else:
		air_simulate(input, state)


func normalized_dir_from_axis(inputaxis: Vector2) -> Vector3:
	var dir := Vector3(0,0,0)

	dir += body.global_basis.z * inputaxis.x
	dir += body.global_basis.x * inputaxis.y

	dir = dir.normalized()

	return dir

func is_inputting_directions(input: CoonInputContainer) -> bool:
	var axis: Vector2 = input.inputaxis

	return axis.length() != 0

func air_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir = normalized_dir_from_axis(input.inputaxis)

	body.position = state.statePosition
	body.velocity = state.stateVelocity

	body.velocity.y -= GRAVITY * get_physics_process_delta_time()
	body.velocity += dir * air_acceleration * get_physics_process_delta_time()
	
	body.move_and_slide()
	return CoonStateContainer.new(body.position, body.velocity)


func ground_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir = normalized_dir_from_axis(input.inputaxis)

	body.position = state.statePosition
	body.velocity = state.stateVelocity

	body.velocity += dir * ground_acceleration * get_physics_process_delta_time()

	if body.velocity.length() > max_ground_speed or not is_inputting_directions(input):
		print("Applying ground friction")
		body.velocity = body.velocity.move_toward(
			Vector3.ZERO, ground_friction * get_physics_process_delta_time()
		)

	body.move_and_slide()
	return CoonStateContainer.new(body.position, body.velocity)


func wallrun_simulate(input: CoonInputContainer, state: CoonStateContainer):
	
	# TODO: Implement Wallrun

	body.move_and_slide()
	return CoonStateContainer.new(body.position, body.velocity)
