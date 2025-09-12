extends RigidBody3D
class_name Ball

@export var accelaration: float = 200
@export var deaccelaration: float = 2

func _physics_process(_delta: float) -> void:
	var input = Vector2(
		int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Backward")),
		int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	).normalized()

	angular_velocity /= deaccelaration
	
	var calculated_velocity = calculate_motion(input)

	calculated_velocity *= 5 if \
	(calculated_velocity.normalized()).distance_to(angular_velocity.normalized()) > 2 else 1

	print(calculated_velocity.normalized(), " | ", angular_velocity.normalized(), " | ", \
	(calculated_velocity.normalized()).distance_to(angular_velocity.normalized()))
	
	angular_velocity += calculated_velocity

func calculate_motion(input):
	return get_physics_process_delta_time() * accelaration * Vector3(input.x, 0, input.y)
	
