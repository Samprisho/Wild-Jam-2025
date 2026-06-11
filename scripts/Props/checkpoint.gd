class_name Checkpoint
extends Area3D

@export var respawnPoint: Marker3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	CheckpointTracker.checkpoint_reached(self, )
	
