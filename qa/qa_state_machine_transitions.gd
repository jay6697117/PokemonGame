extends SceneTree

const FighterStateMachineScript := preload("res://scripts/combat/fighter_state_machine.gd")

func _init() -> void:
	var fsm = FighterStateMachineScript.new()
	var trace: Array[String] = [fsm.get_state_name(fsm.current_state)]
	var sequence: Array[int] = [
		FighterStateMachineScript.FighterState.MOVE,
		FighterStateMachineScript.FighterState.ATTACK,
		FighterStateMachineScript.FighterState.HITSTUN,
		FighterStateMachineScript.FighterState.IDLE,
	]

	for target_state: int in sequence:
		if not fsm.transition_to(target_state):
			printerr("Transition failed at state %s" % fsm.get_state_name(target_state))
			quit(1)
			return
		trace.append(fsm.get_state_name(fsm.current_state))

	var rendered_trace := "->".join(trace)
	if rendered_trace != "IDLE->MOVE->ATTACK->HITSTUN->IDLE":
		printerr("Unexpected transition trace: %s" % rendered_trace)
		quit(1)
		return

	print("QA_STATE_MACHINE_OK")
	print(rendered_trace)
	quit(0)
