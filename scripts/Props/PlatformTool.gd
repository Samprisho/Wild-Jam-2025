@tool
extends AnimatableBody3D
class_name MovablePlatform

## A platform that automatically tweens itself to a path at runtime

var tween: Tween

@export var mesh: Mesh:
	set(new_mesh):
		mesh = new_mesh
		call_deferred("_reset_properties")

@export var collision: Shape3D:
	set(new_collider):
		collision = new_collider
		call_deferred("_reset_properties")

@export var path: Curve3D:
	set(new_path):
		path = new_path
		call_deferred("_reset_properties")

@export var transitionType: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var duration: float = 7
@export var pingPong: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		_reset_properties()
	else: 
		_configure_tween()
	

func _reset_properties() -> void:
	%Mesh.mesh = mesh
	%Collision.shape = collision
	%Path3D.curve = path
	%Path3D.position = global_position


func _configure_tween() -> void:
	# Don't waste resources
	if path.point_count < 1:
		return
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_loops(0)
	
	var pointDurationPingPongAccounted: float = (duration * 2) if pingPong else duration
	pointDurationPingPongAccounted /= path.point_count
	
	
	for i in range(path.point_count):
		var pos: Vector3 = path.get_point_position(i)
		tween.tween_property(self, "position", position + pos, pointDurationPingPongAccounted).set_trans(transitionType)
	
	var reverseRange = range(path.point_count)
	reverseRange.reverse()
	
	if pingPong:
		for i in reverseRange:
			var pos: Vector3 = path.get_point_position(i)
			tween.tween_property(self, "position", position + pos, pointDurationPingPongAccounted).set_trans(transitionType)
	print("Tweened")
