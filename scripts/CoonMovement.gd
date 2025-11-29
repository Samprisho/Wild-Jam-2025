extends Node
class_name CoonMovement

@export var body: Coon

@export_category("Grounded")
@export var ground_acceleration: float = 15
@export var ground_counteract_factor: float = 2.5
@export var ground_friction: float = 15
@export var max_ground_speed: float = 5
@export var jump_veloctiy: float = 6

@export_category("Airborne")
@export var air_acceleration: float = 6
@export var air_slowdown_factor: float = 2
@export var max_air_speed: float = 80

@export_category("Wallrun")
@export var wallrun_acceleration: float = 5
@export var wallrun_friction: float = 4
@export var max_wallrun_speed: float = 30


var stateChart: StateChart
var collisionMesh: CapsuleMesh
var ownedBall: Ball

var clientRotation: Vector3 = Vector3.ZERO

var GRAVITY: float = ProjectSettings.get("physics/3d/default_gravity")

class CoonStateContainer:
	func _init(body:Coon) -> void:
		self.statePosition = body.position
		self.stateVelocity = body.velocity
		self.stateOnFloor = body.is_on_floor()

	
	var statePosition: Vector3
	var stateVelocity: Vector3
	var stateOnFloor: bool

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

func _process(delta):
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
	var state = CoonStateContainer.new(body)

	simulate(input, state)


func normalized_dir_from_axis(inputaxis: Vector2) -> Vector3:
	var dir := Vector3(0,0,0)

	dir += body.global_basis.z * inputaxis.x
	dir += body.global_basis.x * inputaxis.y

	dir = dir.normalized()

	return dir

func is_inputting_directions(input: CoonInputContainer) -> bool:
	var axis: Vector2 = input.inputaxis

	return axis.length() != 0

func simulate(input: CoonInputContainer, state: CoonStateContainer):
	if state.stateOnFloor:
		ground_simulate(input, state)
	else:
		air_simulate(input, state)

func air_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir = normalized_dir_from_axis(input.inputaxis)

	body.position = state.statePosition
	body.velocity = state.stateVelocity

	body.velocity.y -= GRAVITY * get_physics_process_delta_time()
	
	print(air_acceleration - (clamp(body.velocity.normalized().dot(dir), 0, 1) * air_acceleration))
	body.velocity += dir * (air_acceleration - (clamp(body.velocity.normalized().dot(dir), 0, 1) * air_acceleration)) * get_physics_process_delta_time()

	body.move_and_slide()
	return CoonStateContainer.new(body)


func ground_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir = normalized_dir_from_axis(input.inputaxis)

	body.position = state.statePosition
	body.velocity = state.stateVelocity

	var dirDiff: float = dir.dot(body.velocity.normalized())

	# Apply ground accelaration, if the coon's velocity is pointing away from
	# input direction, amplify applied accelaration
	# TODO: Clean up unreadable codebelow
	body.velocity += dir * \
		(ground_acceleration if dirDiff > 0 else ground_acceleration * ground_counteract_factor) \
		* get_physics_process_delta_time()

	if body.velocity.length() > max_ground_speed or not is_inputting_directions(input):
		body.velocity = body.velocity.move_toward(
			Vector3.ZERO, ground_friction * get_physics_process_delta_time()
		)
	
	if input.attemptingJump:
		print("Jump")
		body.velocity.y += jump_veloctiy

	body.move_and_slide()
	return CoonStateContainer.new(body)


func wallrun_simulate(input: CoonInputContainer, state: CoonStateContainer):
	
	# TODO: Implement Wallrun

	body.move_and_slide()
	return CoonStateContainer.new(body)
