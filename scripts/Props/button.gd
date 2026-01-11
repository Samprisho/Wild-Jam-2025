extends GoalCondition

@export var interaction: InteractionComponent

func _ready() -> void:
	interaction.interacted.connect(
		func(interactor):
			complete()
	)
