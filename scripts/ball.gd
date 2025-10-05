extends RigidBody3D
class_name Ball

@export var accelaration: float = 200
@export var deaccelaration: float = 1.01
@export var brakeVelocityMultiplyer: float = 5
@export var brakeVelocityMultiplyerThreshold: float = 0.9
@export var sizeInterpSpeed: float = 1
@export var spinBrakePower: float = 15
@export var jumpPower: float = 1.8

@export var size: float = 1

@export var springArm: SpringArm3D

@onready var collider: CollisionShape3D = $CollisionShape3D

var collisionSphere: SphereShape3D
@onready var initalMass: float = mass
var initalFloorCastY: float

func _ready() -> void:
	collisionSphere = collider.shape as SphereShape3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Respawn"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var input = Vector2(
		int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Backward")),
		int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	) * -1
	
	
	if Input.is_action_pressed("Jump") && on_floor():
		linear_velocity.y += jumpPower
	
	scale = Vector3(size, size, size)
	angular_velocity /= deaccelaration
	
	var calculated_velocity = calculate_motion(input)
	var actualDirection = Vector2(angular_velocity.x, angular_velocity.z).normalized()
	var desiredDirection = Vector2(calculate_desired_rotation_direction(input).x, calculate_desired_rotation_direction(input).z).normalized()
	
	var difference = abs(desiredDirection.angle() - actualDirection.angle())
	
	angular_velocity += calculated_velocity * (brakeVelocityMultiplyer if difference >= 1 else 1)
	
	if !Input.is_action_pressed("Ability 1"):
		angular_velocity = lerp(angular_velocity, Vector3.ZERO, delta * spinBrakePower)

func calculate_motion(input):
	var dir = calculate_desired_rotation_direction(input)
	
	return get_physics_process_delta_time() * accelaration * dir

func calculate_desired_rotation_direction(input: Vector2):
	var dir = ((springArm.global_basis.x.normalized() * input.x) + (springArm.global_basis.z.normalized() * input.y)).normalized()
	return dir
func calculate_desired_linear_direction(input: Vector2): 
	pass

func reset_collision_shape():
	collisionSphere.radius = size * 0.5
	mass = initalMass * size
	jumpPower = jumpPower + (size / 10)
func on_floor() -> bool:
	var floor: StaticBody3D = get_colliding_bodies()[0] if get_colliding_bodies().size() > 0 else null
	if floor:
		if floor.collision_layer == 1:
			return true
	
	return false
