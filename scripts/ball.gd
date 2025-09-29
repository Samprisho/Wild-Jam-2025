extends RigidBody3D
class_name Ball

@export var accelaration: float = 200
@export var deaccelaration: float = 1.05
@export var brakeVelocityMultiplyer: float = 5
@export var brakeVelocityMultiplyerThreshold: float = 0.9
@export var springArm: Node3D

func _physics_process(_delta: float) -> void:
	var input = Vector2(
		int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Backward")),
		int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	) * -1

	angular_velocity /= deaccelaration
	
	var calculated_velocity = calculate_motion(input)
	var actualDirection = Vector2(angular_velocity.x, angular_velocity.z).normalized()
	var desiredDirection = Vector2(calculate_desired_rotation_direction(input).x, calculate_desired_rotation_direction(input).z).normalized()
	
	var difference = abs(desiredDirection.angle() - actualDirection.angle())
	
	
	angular_velocity += calculated_velocity * (brakeVelocityMultiplyer if difference >= 1 else 1)

func calculate_motion(input):
	var dir = calculate_desired_rotation_direction(input)
	
	return get_physics_process_delta_time() * accelaration * dir

func calculate_desired_rotation_direction(input: Vector2):
	var dir = ((springArm.global_basis.x.normalized() * input.x) + (springArm.global_basis.z.normalized() * input.y)).normalized()
	return dir
func calculate_desired_linear_direction(input: Vector2): 
	pass
