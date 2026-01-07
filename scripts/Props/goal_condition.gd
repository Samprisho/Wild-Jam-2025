extends Node3D
class_name GoalCondition

signal condition_fulfilled
signal condition_reverted
signal condition_changed(state: bool, condition: GoalCondition)

var fulfilled: bool = false

# Add more condition types as development continues
enum EConditionType {
	PRESSURE_PLATE = 0,
	BUTTON,
}

func complete():
	fulfilled = true
	condition_fulfilled.emit()
	condition_changed.emit(fulfilled, self)

func revert():
	fulfilled = false
	condition_reverted.emit()
	condition_changed.emit(fulfilled, self)
