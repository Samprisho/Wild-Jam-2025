extends CharacterBody3D
class_name Coon

var relatedBall: Ball

@onready var movement: CoonMovement = $CoonMovementComponent

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
