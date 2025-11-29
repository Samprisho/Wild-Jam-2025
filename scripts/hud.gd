extends Control

@onready var showPosLabel: Label = $showPos

func _ready():
	ClientUi.showPos.connect(_on_showPos)

func _on_showPos(info: String):
	showPosLabel.text = info
