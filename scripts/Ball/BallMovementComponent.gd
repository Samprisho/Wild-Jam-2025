extends Node
class_name BallMovementComponent

@export_category("Relations")
@export var body: Ball

@export_category("Grounded")
@export var ground_acceleration: float = 20
@export var ground_counteract_factor: float = 5
@export var ground_friction: float = 3
@export var max_ground_speed: float = 7
@export var push_force: float = 1



@export_category("Airborne")
@export var air_acceleration: float = 3
@export var air_slowdown_factor: float = 10
@export var air_drag: float = 10
@export var max_air_speed: float = 20

var jump_veloctiy: float = 1

var GRAVITY: float = ProjectSettings.get("physics/3d/default_gravity")

enum EMovementState{
	GROUNDED = 0,
	AIRBORNE,
}

class BallStateContainer:
	func _init(body:Ball) -> void:
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

class BallInputContainer:
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

func _physics_process(delta: float) -> void:
	
	var inputDir: Vector2
	
	if body.ballOnlyMode:
		inputDir = Vector2(
			# Remember, -Z is forward, and Z is backward
			Input.get_axis("Forward", "Backward"),
			Input.get_axis("Left", "Right")
		)
	
	if body.ownedCoon and body.coonInside:
		inputDir = Vector2(
			# Remember, -Z is forward, and Z is backward
			Input.get_axis("Forward", "Backward"),
			Input.get_axis("Left", "Right")
		)
	else:
		inputDir = Vector2(0,0)
	
	var jumping: bool = Input.is_action_pressed("Jump")
	var crouching: bool = Input.is_action_pressed("Ability 1")

	var input = BallInputContainer.new(inputDir, jumping, crouching)
	var state = BallStateContainer.new(body)
	
	simulate(input, state)

func normalized_dir_from_axis(inputaxis: Vector2) -> Vector3:
	var dir := Vector3(0,0,0)
	
	var rotated = Vector3.BACK.rotated(Vector3.UP, body.camComponent.springArm.global_rotation.y)
	
	dir += rotated * inputaxis.x
	dir += body.springArm.global_basis.x * inputaxis.y

	dir = dir.normalized()

	return dir

func simulate(input: BallInputContainer, state: BallStateContainer):
	var newState: BallStateContainer

	if state.stateOnFloor:
		newState = ground_simulate(input, state)
		newState.movementState = EMovementState.GROUNDED
	else:
		newState = air_simulate(input, state)
		newState.movementState = EMovementState.AIRBORNE
	

	return newState

func air_simulate(input: BallInputContainer, state: BallStateContainer):
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
	
	if velWithouty.length() > max_air_speed:
		var target = Vector3.ZERO
		target.y = body.velocity.y
		
		body.velocity = body.velocity.move_toward(
			target, air_slowdown_factor * get_physics_process_delta_time()
		)
		print("slowing down")
	
	body.velocity -= Vector3.UP * GRAVITY * delta

	body.move_and_slide()
	return BallStateContainer.new(body)


func ground_simulate(input: BallInputContainer, state: BallStateContainer):
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

	
	if body.velocity.length() > 0:
		body.velocity = body.velocity.move_toward(
			Vector3.ZERO, ground_friction * get_physics_process_delta_time()
		)
	
	var norm = Vector3(body.get_floor_normal().x, 0, body.get_floor_normal().z)
	body.velocity += norm * get_physics_process_delta_time() * GRAVITY
	
	if input.attemptingJump:
		body.velocity.y += jump_veloctiy
	
	body.move_and_slide()
	
	for i in body.get_slide_collision_count():
		var c:KinematicCollision3D = body.get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
				
	return BallStateContainer.new(body)
