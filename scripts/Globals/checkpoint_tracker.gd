extends Node

var lastCheckpointPlayerState: CoonMovement.CoonStateContainer
var lastCheckpoint: Checkpoint = null

signal restoringCheckpoint(checkpoint: Checkpoint)

func retry_last_checkpoint() -> bool:
	if not lastCheckpoint:
		push_error("CHECKPOINT ERROR: There is no checkpoint to retry to")
		return false
	
	restoringCheckpoint.emit(lastCheckpoint)
	return true

func checkpoint_reached(newCheckpoint: Checkpoint):
	lastCheckpoint = newCheckpoint
	
	GameSaver.save_current_state()
