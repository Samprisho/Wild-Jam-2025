extends Node3D
class_name GoalCondition

## Holds the state of being fulfilled or not fulfilled. [br]
##
##
## This Node works in tandem with [PropActivator]

## Fires when [method complete] is called
signal condition_fulfilled

## Fires when [method revert] is called
signal condition_reverted

## General signal indicating a change in the goal condition's fulfillment
signal condition_changed(state: bool, condition: GoalCondition)

var fulfilled: bool = false

# Add more condition types as development continues
enum EConditionType {
	PRESSURE_PLATE = 0,
	BUTTON,
}

## Marks goal condition as fulfilled (true) [br] [br]
## Should be called by extending class to mark goal condition as fulfilled and
## notify any connected [PropActivator]s
func complete():
	fulfilled = true
	condition_fulfilled.emit()
	condition_changed.emit(fulfilled, self)

## Should be called by extending class to mark goal condition as unfulfilled and
## notify any connected [PropActivator]s
func revert():
	fulfilled = false
	condition_reverted.emit()
	condition_changed.emit(fulfilled, self)
