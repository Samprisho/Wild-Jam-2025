extends PropActivator
class_name JumpPad

##
## This is a jump pad! 
##
## The jump pad will propel whatever lands on it towards the [member launchDirectionNode]

@export var detactionArea: Area3D
@export var launchDirectionNode: Marker3D

@export_category("Launch properties")
@export var jumpPadPower: float = 13
@export var velocityOverride: bool = true

func _ready() -> void:
	super()
	detactionArea.body_entered.connect(_on_body_detected)

func _on_body_detected(body: Node3D):
	if not fulfilled:
		print(name + " conditions unfulfilled")
		return
	
	if body is Coon:
		body.velocity.y = 0
		var result: Vector3 = Vector3.ZERO
		var direction = global_position.direction_to(launchDirectionNode.global_position)
		
		result = direction * jumpPadPower + body.velocity
		
		print(result)
		
		body.apply_impulse(result, velocityOverride)
		
		
	
	print("Jumping ", body.name)
