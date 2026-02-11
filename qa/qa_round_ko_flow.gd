extends SceneTree

const RoundManagerScript := preload("res://scripts/match/round_manager.gd")

func _init() -> void:
	var manager = RoundManagerScript.new({
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	})

	manager.apply_damage("p2", 1000)

	var snapshot_after_ko: Dictionary = manager.get_hud_snapshot()
	var p1_score := int(snapshot_after_ko.get("p1_rounds", 0))
	if p1_score != 1:
		printerr("Expected p1 score 1 after KO, got %d" % p1_score)
		quit(1)
		return

	if str(snapshot_after_ko.get("phase", "")) != RoundManagerScript.PHASE_ROUND_END:
		printerr("Expected ROUND_END phase after KO")
		quit(1)
		return

	if not manager.start_next_round():
		printerr("Failed to start next round after KO")
		quit(1)
		return

	var snapshot_next_round: Dictionary = manager.get_hud_snapshot()
	if str(snapshot_next_round.get("phase", "")) != RoundManagerScript.PHASE_ROUND_ACTIVE:
		printerr("Expected ROUND_ACTIVE phase after next round start")
		quit(1)
		return

	print("QA_ROUND_KO_FLOW_OK")
	print("ROUND_SCORE_P1:%d" % p1_score)
	print("NEXT_ROUND_STARTED")
	quit(0)
