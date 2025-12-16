extends Node
class_name CoonMovement

@export var body: Coon
@export var camera: CoonCameraComponent

@export var stateChart: StateChart

@export_category("Grounded")
@export var ground_acceleration: float = 20
@export var ground_counteract_factor: float = 5
@export var ground_friction: float = 40
@export var max_ground_speed: float = 7
@export var jump_veloctiy: float = 9

@export_category("Airborne")
@export var air_acceleration: float = 3
@export var air_slowdown_factor: float = 10
@export var air_drag: float = 10
@export var max_air_speed: float = 5

@export_category("Wallrun")
@export var wallrun_acceleration: float = 5
@export var wallrun_friction: float = 4
@export var max_wallrun_speed: float = 30

var MAX_DICT_HISTORY_LENGTH = 60

enum EMovementState{
	GROUNDED = 0,
	AIRBORNE,
	WALLRUNNING,
	MANTLE
}
var collisionMesh: CapsuleMesh
var ownedBall: Ball

var clientRotation: Vector3 = Vector3.ZERO
var GRAVITY: float = ProjectSettings.get("physics/3d/default_gravity")

var pastInputs = {}
var pastStates = {}

var timeStamp: int = 0

class CoonStateContainer:
	func _init(body:Coon) -> void:
		self.statePosition = body.position
		self.stateVelocity = body.velocity
		self.stateOnFloor = body.is_on_floor()

	func _to_string() -> String:
		var result: String = ""
		
		result += "State: " + str(movementState) + "\n"
		result += "Pos: "+ str(statePosition) + "\n" 
		result += "Vel: "+ str(Vector2(stateVelocity.x, stateVelocity.z).length()) \
				+ " Y: "+ str(stateVelocity.y) + "\n"

		return result
	var statePosition: Vector3
	var stateVelocity: Vector3
	var stateOnFloor: bool
	var movementState: EMovementState = EMovementState.GROUNDED

class CoonInputContainer:
	func _init(axis, jumping, crouching) -> void:
		self.inputaxis = axis
		self.attemptingJump = jumping
		self.attemptingCrouch = crouching
	
	func _to_string() -> String:
		var result = ""
		
		result += "X: " + str(inputaxis.x) + " | Y: " + str(inputaxis.y) + '\n'
		result += "Jumping: " + str(attemptingJump) + '\n'
		result += "Crouching: " + str(attemptingCrouch) + '\n'
		
		return result

	var inputaxis: Vector2
	var attemptingJump: bool
	var attemptingCrouch: bool

	
func _physics_process(_delta: float) -> void:

	clear_past_history()
	
	if body.relatedBall.coonInside:
		return
	
	var inputDir: Vector2 = Vector2(
		# Remember, -Z is forward, and Z is backward
		Input.get_axis("Forward", "Backward"),
		Input.get_axis("Left", "Right")
	)

	var jumping: bool = Input.is_action_pressed("Jump")

	var crouching: bool = Input.is_action_pressed("Ability 1")

	var input = CoonInputContainer.new(inputDir, jumping, crouching)
	pastInputs[timeStamp] = input
	
	print(pastInputs.size())
	
	var state = CoonStateContainer.new(body) if pastStates.size() == 0 else pastStates.get(timeStamp - 1)
	var newState = simulate(input, state)
	pastStates[timeStamp] = newState
	timeStamp += 1


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
	var newState: CoonStateContainer

	if state.stateOnFloor:
		newState = ground_simulate(input, state)
		newState.movementState = EMovementState.GROUNDED
	else:
		newState = air_simulate(input, state)
		newState.movementState = EMovementState.AIRBORNE
	
	if stateChart:
		if state.stateOnFloor == true and newState.stateOnFloor == false:
			print("sent jump event")
			stateChart.send_event("jump")
		
		if state.stateOnFloor == false and newState.stateOnFloor == true:
			print("sent grounded event")
			stateChart.send_event("grounded")

		if state.stateOnFloor == false and newState.stateOnFloor == false and \
		  sign(state.stateVelocity.y) != sign(newState.stateVelocity.y):
			print("staled")
			stateChart.send_event("stale") 

	ClientUi.showPos.emit(newState.to_string() + pastInputs[timeStamp].to_string())
	return newState


func air_simulate(input: CoonInputContainer, state: CoonStateContainer):
	var dir := normalized_dir_from_axis(input.inputaxis)
	var delta = get_physics_process_delta_time()

	body.position = state.statePosition
	body.velocity = state.stateVelocity
	
	# This next section is just quake 1999 implementation
	# of sv_accelerate
	var wish_vel = dir * max_ground_speed
	var wish_normal = wish_vel.normalized()
	var wish_air_speed = clampf(wish_vel.length(), 0, max_air_speed * 0.3)
	
	var velWithouty = Vector3(body.velocity.x, 0, body.velocity.z)
	
	var wish_diff = wish_normal.dot(body.velocity)
	

	var speed_to_add = wish_air_speed - wish_diff
	speed_to_add = clampf(speed_to_add, 0, INF)
	
	var accel_speed = wish_vel.length() * air_acceleration * delta
	if (accel_speed > speed_to_add):
		accel_speed = speed_to_add
	
	body.velocity += wish_normal * accel_speed
	
	#if velWithouty.length() > max_air_speed:
		#var target = Vector3.ZERO
		#target.y = body.velocity.y
		#
		#body.velocity = body.velocity.move_toward(
			#target, air_slowdown_factor * get_physics_process_delta_time()
		#)
		#print("slowing down")
	
	body.velocity -= Vector3.UP * GRAVITY * delta

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

func clear_past_history():
	if pastInputs.size() > MAX_DICT_HISTORY_LENGTH:
		pastInputs.erase(timeStamp - MAX_DICT_HISTORY_LENGTH)
	if pastStates.size() > MAX_DICT_HISTORY_LENGTH:
		pastStates.erase(timeStamp - MAX_DICT_HISTORY_LENGTH)
