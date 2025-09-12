extends RigidBody3D
class_name Ball

@export var accelaration: float = 70

func _physics_process(_delta: float) -> void:
	var input = Vector2(
		int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Backward")),
		int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	)
	
	var calculated_velocity = calculate_motion(input)
	
	angular_velocity += calculated_velocity

func calculate_motion(input):
	return get_physics_process_delta_time() * accelaration * Vector3(input.x, 0, input.y)
	
