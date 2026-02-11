extends SceneTree

const RoundManagerScript := preload("res://scripts/match/round_manager.gd")

func _init() -> void:
	var manager = RoundManagerScript.new({
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	})

	manager.set_hp_for_test(600, 600)
	manager.tick_seconds(60.0)

	var snapshot: Dictionary = manager.get_hud_snapshot()
	if int(snapshot.get("p1_rounds", -1)) != 0 or int(snapshot.get("p2_rounds", -1)) != 0:
		printerr("Timeout tie should not change round scores")
		quit(1)
		return

	if str(manager.last_event) != "round_restarted_on_tie":
		printerr("Expected tie restart event, got %s" % str(manager.last_event))
		quit(1)
		return

	if int(manager.tie_restart_count) < 1:
		printerr("Expected tie_restart_count >= 1")
		quit(1)
		return

	print("QA_TIMEOUT_TIE_RULE_OK")
	print("ROUND_RESTARTED_ON_TIE")
	quit(0)
