extends RefCounted
class_name FixedTickCombatLoop

const FighterStateMachineScript := preload("res://scripts/combat/fighter_state_machine.gd")

const TICK_RATE := 60
const FIXED_STEP_SECONDS := 1.0 / float(TICK_RATE)

func run(scripted_inputs: Dictionary, total_ticks: int) -> PackedStringArray:
	var fsm = FighterStateMachineScript.new()
	var trace: PackedStringArray = []
	var accumulator := 0.0
	var simulated_seconds := 0.0

	for tick in total_ticks:
		accumulator += FIXED_STEP_SECONDS

		while accumulator >= FIXED_STEP_SECONDS:
			_apply_scripted_input(fsm, scripted_inputs, tick)
			trace.append("%d:%s" % [tick, fsm.get_state_name(fsm.current_state)])
			_apply_post_tick_transitions(fsm)
			accumulator -= FIXED_STEP_SECONDS
			simulated_seconds += FIXED_STEP_SECONDS

	var expected_seconds := float(total_ticks) * FIXED_STEP_SECONDS
	if absf(expected_seconds - simulated_seconds) > 0.00001:
		trace.append("TIMING_DRIFT")

	return trace

func _apply_scripted_input(fsm: RefCounted, scripted_inputs: Dictionary, tick: int) -> void:
	if not scripted_inputs.has(tick):
		return

	var input_name := str(scripted_inputs[tick]).to_lower()
	match input_name:
		"move":
			fsm.transition_to(FighterStateMachineScript.FighterState.MOVE)
		"jump":
			fsm.transition_to(FighterStateMachineScript.FighterState.JUMP)
		"crouch":
			fsm.transition_to(FighterStateMachineScript.FighterState.CROUCH)
		"attack":
			fsm.transition_to(FighterStateMachineScript.FighterState.ATTACK)
		"hitstun":
			fsm.transition_to(FighterStateMachineScript.FighterState.HITSTUN)
		"ko":
			fsm.transition_to(FighterStateMachineScript.FighterState.KO)
		"idle":
			fsm.transition_to(FighterStateMachineScript.FighterState.IDLE)

func _apply_post_tick_transitions(fsm: RefCounted) -> void:
	match fsm.current_state:
		FighterStateMachineScript.FighterState.ATTACK:
			fsm.transition_to(FighterStateMachineScript.FighterState.HITSTUN)
		FighterStateMachineScript.FighterState.HITSTUN:
			fsm.transition_to(FighterStateMachineScript.FighterState.IDLE)
		FighterStateMachineScript.FighterState.MOVE:
			fsm.transition_to(FighterStateMachineScript.FighterState.IDLE)
		FighterStateMachineScript.FighterState.JUMP:
			fsm.transition_to(FighterStateMachineScript.FighterState.IDLE)
		FighterStateMachineScript.FighterState.CROUCH:
			fsm.transition_to(FighterStateMachineScript.FighterState.IDLE)
		_:
			pass
