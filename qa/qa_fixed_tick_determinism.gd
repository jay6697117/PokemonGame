extends SceneTree

const FixedTickCombatLoopScript := preload("res://scripts/combat/fixed_tick_combat_loop.gd")

func _init() -> void:
	if Engine.physics_ticks_per_second != 60:
		printerr("physics_ticks_per_second must be 60")
		quit(1)
		return

	var scripted_inputs := {
		1: "move",
		3: "attack",
		6: "jump",
		9: "crouch",
	}

	var loop = FixedTickCombatLoopScript.new()
	var trace_a := loop.run(scripted_inputs, 12)
	var trace_b := loop.run(scripted_inputs, 12)

	if trace_a.size() != trace_b.size():
		printerr("Determinism failed: trace sizes differ")
		quit(1)
		return

	for index in trace_a.size():
		if trace_a[index] != trace_b[index]:
			printerr("Determinism failed at index %d" % index)
			quit(1)
			return

	if trace_a.has("TIMING_DRIFT"):
		printerr("Fixed tick loop reported timing drift")
		quit(1)
		return

	print("QA_FIXED_TICK_OK")
	print("TRACE_SAMPLE:%s" % trace_a[0])
	quit(0)
