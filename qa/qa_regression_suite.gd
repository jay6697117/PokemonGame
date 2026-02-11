extends SceneTree

const RoundManagerScript := preload("res://scripts/match/round_manager.gd")
const LocalInputManagerScript := preload("res://scripts/input/local_input_manager.gd")
const FighterSchemaValidatorScript := preload("res://scripts/roster/fighter_schema_validator.gd")

func _init() -> void:
	var total_cases := 4
	var passed_cases := 0

	if _edge_case_double_ko_restart():
		passed_cases += 1
	if _edge_case_timeout_tie_restart():
		passed_cases += 1
	if _edge_case_focus_loss_clears_input():
		passed_cases += 1
	if _edge_case_invalid_schema_rejected():
		passed_cases += 1

	if passed_cases != total_cases:
		printerr("Regression suite failed: %d/%d" % [passed_cases, total_cases])
		quit(1)
		return

	print("QA_REGRESSION_OK")
	print("EDGE_CASES:%d/%d" % [passed_cases, total_cases])
	quit(0)

func _edge_case_double_ko_restart() -> bool:
	var manager = RoundManagerScript.new({
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	})
	manager.resolve_double_ko()
	return str(manager.last_event) == "double_ko_tie_restart" and int(manager.tie_restart_count) >= 1

func _edge_case_timeout_tie_restart() -> bool:
	var manager = RoundManagerScript.new({
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	})
	manager.set_hp_for_test(700, 700)
	manager.tick_seconds(60.0)
	return str(manager.last_event) == "round_restarted_on_tie"

func _edge_case_focus_loss_clears_input() -> bool:
	var input_manager = LocalInputManagerScript.new(6)
	input_manager.set_player_action_pressed("p1", "left", true)
	input_manager.set_player_action_pressed("p2", "right", true)
	input_manager.simulate_focus_lost()
	return input_manager.total_stuck_keys() == 0

func _edge_case_invalid_schema_rejected() -> bool:
	var validator = FighterSchemaValidatorScript.new()
	var invalid_data := {
		"id": "broken",
		"name": "Broken",
		"placeholder_asset_id": "broken_asset",
		"base_stats": {
			"hp": 1000,
			"speed": 1.0,
			"weight": 1.0,
		},
	}
	var result: Dictionary = validator.validate_fighter_data(invalid_data)
	return not bool(result.get("valid", true)) and str(result.get("error_code", "")) == "ERR_SCHEMA_FIELD_MISSING"
