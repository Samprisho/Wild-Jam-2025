extends Node3D
class_name PropActivator

@export var conditions: Array[GoalCondition] = []

var fulfilled: bool = false

## This signal emits when an individual condition inside conditions changes state,
## NOT when there is a change in the fulfillment of every condition  
signal individual_condition_change(state: bool, condition: GoalCondition)

signal prop_activate
signal prop_deactivate

func _ready() -> void:
	for condition in conditions:
		condition.condition_changed.connect(_on_conditions_changed)

func _on_conditions_changed(state: bool, condition: GoalCondition):
	fulfilled = _evaluate_conditions()
	individual_condition_change.emit(state, condition)
	
	if fulfilled:
		prop_activate.emit()
	else:
		prop_deactivate.emit()
	

## Compare conditions with 'AND' essentially 
func _evaluate_conditions() -> bool:
	var result: bool = true
	
	# If every condition is true, then fulfilled should be true
	for condition in conditions:
		if not condition.fulfilled:
			result = false
			break
	
	print("evaluating", result)
	
	return result
