extends Node3D

@export var collision: Area3D

func _ready() -> void:
	collision.body_entered.connect(
		func(body: Node3D):
			var hp = body.find_child("HealthComponent")
			print("entered! ")
			
			if hp:
				print("not null!")
				if hp is HealthComponent:
					var healthComponent: HealthComponent = hp as HealthComponent
					healthComponent.apply_damage(self, 1000)
	)
