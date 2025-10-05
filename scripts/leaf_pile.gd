extends Node3D

@export var area: Area3D

@export var value: float = 0.4

func _ready() -> void:
	area.body_entered.connect(_area_entered)
	scale = Vector3(value, 1, value)
	
func _area_entered(body) -> void:
	var ball: Ball = body as Ball
	print(body)
	
	if !ball:
		return
	
	ball.size += value / ball.size
	ball.reset_collision_shape()
	
	queue_free()
	
