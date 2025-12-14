extends AnimatableBody3D

@export var anim: AnimationPlayer

func _ready() -> void:
	anim.autoplay = "move"
	anim.get_animation("move").loop_mode = Animation.LOOP_LINEAR
	anim.play("move")
	
