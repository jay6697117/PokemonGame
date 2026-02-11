extends SceneTree

const MatchFlowControllerScript := preload("res://scripts/flow/match_flow_controller.gd")

func _init() -> void:
	var flow = MatchFlowControllerScript.new()
	var fighter_ids: Array[String] = flow.get_available_fighter_ids()
	if fighter_ids.size() < 2:
		printerr("Expected at least 2 fighters for rematch reset test")
		quit(1)
		return

	if not bool(flow.select_fighter("p1", fighter_ids[0]).get("ok", false)):
		printerr("P1 selection failed")
		quit(1)
		return
	if not bool(flow.select_fighter("p2", fighter_ids[1]).get("ok", false)):
		printerr("P2 selection failed")
		quit(1)
		return

	if not bool(flow.begin_fight().get("ok", false)):
		printerr("begin_fight failed")
		quit(1)
		return

	flow.queue_test_input("p1", "attack", 10)
	flow.set_test_pressed("p1", "left", true)

	flow.apply_damage("p2", 1000)

	var rematch_result: Dictionary = flow.request_rematch()
	if not bool(rematch_result.get("ok", false)):
		printerr("request_rematch failed")
		quit(1)
		return

	var hp_reset := bool(rematch_result.get("hp_reset", false))
	var input_buffer_cleared := bool(rematch_result.get("input_buffer_cleared", false))
	if not hp_reset or not input_buffer_cleared:
		printerr("Rematch reset flags invalid")
		quit(1)
		return

	print("QA_REMATCH_RESET_OK")
	print("HP_RESET:%s" % str(hp_reset).to_lower())
	print("INPUT_BUFFER_CLEARED:%s" % str(input_buffer_cleared).to_lower())
	quit(0)
