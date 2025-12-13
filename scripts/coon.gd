extends CharacterBody3D
class_name Coon

var relatedBall: Ball

@onready var movement: CoonMovement = $CoonMovementComponent

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_airborne_state_entered() -> void:
	print("Now airborne") 


func _on_rising_state_entered() -> void:
	print("rising up")


func _on_grounded_state_entered() -> void:
	print("on my feet")
