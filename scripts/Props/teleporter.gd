@tool
extends PropActivator
class_name Teleporter

@export_multiline var textLabelContent: String:
	set(newText):
		textLabelContent = newText
		call_deferred("_update_3d_label")

@export var teleporterColor: Color:
	set(newColor):
		teleporterColor = newColor
		call_deferred("_update_color")

@export var cooldownTime: float = 3

@export var destinationNode: Node3D

@export_group("Node references")
@export var label3D: Label3D
@export var padMesh: GeometryInstance3D
@export var collision: Area3D
@export var timer: Timer

func _update_3d_label():
	label3D.text = textLabelContent

func _update_color():
	var mat = padMesh.material_override
	
	if not mat:
		print("no material")
		return
	
	if mat is StandardMaterial3D:
		mat.albedo_color = teleporterColor

func _ready() -> void:
	super()

func _on_teleporter_collision_body_entered(body: Node3D) -> void:
	if body is Coon and timer.is_stopped() and not destinationNode == null:
		
		if destinationNode is Teleporter:
			destinationNode.timer.start(cooldownTime)
		
		body.movement.lastState.statePosition = destinationNode.global_position
		timer.start(cooldownTime)
