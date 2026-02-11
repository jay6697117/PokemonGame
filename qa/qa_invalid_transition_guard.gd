extends SceneTree

const FighterStateMachineScript := preload("res://scripts/combat/fighter_state_machine.gd")

func _init() -> void:
	var fsm = FighterStateMachineScript.new()
	fsm.force_state(FighterStateMachineScript.FighterState.KO)

	var transitioned := fsm.transition_to(FighterStateMachineScript.FighterState.ATTACK)
	if transitioned:
		printerr("Invalid transition unexpectedly succeeded")
		quit(1)
		return

	if fsm.current_state != FighterStateMachineScript.FighterState.KO:
		printerr("State changed despite guard")
		quit(1)
		return

	if fsm.last_guard_message != "BLOCKED: KO->ATTACK":
		printerr("Unexpected guard message: %s" % fsm.last_guard_message)
		quit(1)
		return

	print("QA_INVALID_TRANSITION_GUARD_OK")
	print(fsm.last_guard_message)
	quit(0)
