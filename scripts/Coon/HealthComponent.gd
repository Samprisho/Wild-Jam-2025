extends Node
class_name HealthComponent

@export_group("Health")
@export var maxHealth: float = 20
@export var startingHealth: float = 5
@export var startWithFullHealth: bool = true

signal death

var health: float = 1
var shouldBeDead: bool = false

func _ready() -> void:
	if startWithFullHealth:
		health = maxHealth
	else:
		health = startingHealth

func apply_damage(source: Node3D, damage: float = 1):
	health -= damage
	
	if health < 0:
		if not shouldBeDead:
			death.emit()
		
		shouldBeDead = true
