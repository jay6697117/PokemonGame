extends SceneTree

const MatchFlowControllerScript := preload("res://scripts/flow/match_flow_controller.gd")

func _init() -> void:
	var flow = MatchFlowControllerScript.new()
	var fighter_ids: Array[String] = flow.get_available_fighter_ids()
	if fighter_ids.size() < 1:
		printerr("No fighters available for flow test")
		quit(1)
		return

	var chosen_fighter := fighter_ids[0]
	var p1_result: Dictionary = flow.select_fighter("p1", chosen_fighter)
	var p2_result: Dictionary = flow.select_fighter("p2", chosen_fighter)
	if not bool(p1_result.get("ok", false)) or not bool(p2_result.get("ok", false)):
		printerr("Character selection failed")
		quit(1)
		return

	var begin_result: Dictionary = flow.begin_fight()
	if not bool(begin_result.get("ok", false)):
		printerr("begin_fight failed")
		quit(1)
		return

	flow.apply_damage("p2", 1000)

	var rematch_result: Dictionary = flow.request_rematch()
	if not bool(rematch_result.get("ok", false)):
		printerr("request_rematch failed")
		quit(1)
		return

	var flow_trace := flow.get_flow_trace_string()
	if flow_trace != "SELECT->FIGHT->RESULT->REMATCH":
		printerr("Unexpected flow trace: %s" % flow_trace)
		quit(1)
		return

	print("QA_FULL_MATCH_FLOW_OK")
	print("FLOW:%s" % flow_trace)
	quit(0)
