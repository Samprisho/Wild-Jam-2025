@tool
extends Node3D

@export var area: Area3D

@export var value: float = 0.4:
	set(newValue):
		value = newValue
		call_deferred("reset_size")

func _ready() -> void:
	area.body_entered.connect(_area_entered)
	reset_size()

	
func _area_entered(body) -> void:
	var ball: Ball = body as Ball
	print(body)
	
	if !ball:
		return
	
	ball.size += value / ball.size
	ball.reset_collision_shape()
	
	queue_free()
	
func reset_size():
	scale = Vector3(value, value * 0.5, value)
