extends RigidBody3D
class_name Ball

@export var accelaration: float = 200
@export var deaccelaration: float = 1.4
@export var springArm: Node3D

func _physics_process(_delta: float) -> void:
	var input = Vector2(
		int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Backward")),
		int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	) * -1

	angular_velocity /= deaccelaration
	
	var calculated_velocity = calculate_motion(input)

	calculated_velocity *= 5 if \
	(calculated_velocity.normalized()).distance_to(angular_velocity.normalized()) > 2 else 1
	
	angular_velocity += calculated_velocity

func calculate_motion(input):
	var dir = ((springArm.global_basis.x * input.x) + (springArm.global_basis.z * input.y)).normalized()
	
	return get_physics_process_delta_time() * accelaration * dir
	
