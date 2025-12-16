@tool
extends AnimatableBody3D

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

func _ready() -> void:
	if Engine.is_editor_hint():
		_reset_properties()
		print("Set our stuff")
	else: 
		configure_tween()
		

func _reset_properties() -> void:
	%Mesh.mesh = mesh
	%Collision.shape = collision
	%Path3D.curve = path

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	

func configure_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_loops(0)
	

	for i in range(path.point_count):
		var pos: Vector3 = path.get_point_position(i)
		tween.tween_property(self, "position", position + pos, duration / path.point_count).set_trans(transitionType)
	print("Tweened")
