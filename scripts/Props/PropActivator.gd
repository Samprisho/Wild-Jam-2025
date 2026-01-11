extends Node3D
class_name PropActivator

## This class can be extended by nodes that need to interact with any 
## goal condition. [br]
## [color=yellow]WARNING: [/color]Please call [code]super()[/code] when overriding [method Node._ready]

## The list of goal conditions that will determine if the prop should be active
## or not. [br]
## Use the Inspector window to pick nodes that inherit from [GoalCondition].
@export var conditions: Array[GoalCondition] = []

var fulfilled: bool = false

## This signal emits when an individual condition inside conditions changes state,
## NOT when there is a change in the fulfillment of every condition  
signal individual_condition_change(state: bool, condition: GoalCondition)

## Fires when all GoalConditions are fulfilled
signal prop_activate
## Fires when a GoalCondition becomes unfulfilled, meaning that the conditions
## This prop should deactivate
signal prop_deactivate

## connect [method _on_conditions_changed] to every [GoalCondition] in
## [member conditions].
func _ready() -> void:
	for condition in conditions:
		condition.condition_changed.connect(_on_conditions_changed)
	
	check_if_fulfilled()

## Is called when any [GoalCondition]s in [member conditions] fire
## [signal GoalCondition.condition_changed]
func _on_conditions_changed(state: bool, condition: GoalCondition):
	fulfilled = _evaluate_conditions()
	individual_condition_change.emit(state, condition)
	
	if fulfilled:
		prop_activate.emit()
	else:
		prop_deactivate.emit()
	

## Compare conditions with 'AND' essentially by iterating through all [GoalCondition]s
## and ensuring they are all fulfilled
func _evaluate_conditions() -> bool:
	var result: bool = true
	
	# If every condition is true, then fulfilled should be true
	for condition in conditions:
		if not condition.fulfilled:
			result = false
			break
	
	print("evaluating", result)
	
	return result

func check_if_fulfilled():
	fulfilled = _evaluate_conditions()
	
	if fulfilled:
		prop_activate.emit()
	else:
		prop_deactivate.emit()
	
