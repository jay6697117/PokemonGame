extends SceneTree

const FighterStateMachineScript := preload("res://scripts/combat/fighter_state_machine.gd")
const LocalInputManagerScript := preload("res://scripts/input/local_input_manager.gd")
const HitResolutionServiceScript := preload("res://scripts/combat/damage/hit_resolution_service.gd")
const RoundManagerScript := preload("res://scripts/match/round_manager.gd")

func _init() -> void:
	var failures: Array[String] = []

	if not _test_state_machine_transition():
		failures.append("state machine transition test failed")
	if not _test_input_buffer_single_consume():
		failures.append("input buffer single consume test failed")
	if not _test_hit_resolution_single_apply():
		failures.append("hit resolution test failed")
	if not _test_round_timeout_tie_behavior():
		failures.append("round timeout tie behavior test failed")

	if failures.is_empty():
		print("TESTS_ALL_PASS")
		quit(0)
		return

	for failure in failures:
		printerr(failure)
	quit(1)

func _test_state_machine_transition() -> bool:
	var fsm = FighterStateMachineScript.new()
	if not fsm.transition_to(FighterStateMachineScript.FighterState.MOVE):
		return false
	if not fsm.transition_to(FighterStateMachineScript.FighterState.ATTACK):
		return false
	return fsm.transition_to(FighterStateMachineScript.FighterState.HITSTUN)

func _test_input_buffer_single_consume() -> bool:
	var input_manager = LocalInputManagerScript.new(6)
	input_manager.record_player_action("p1", "attack", 10)
	var first_result: Dictionary = input_manager.consume_player_action("p1", ["attack"], 12)
	if first_result.is_empty():
		return false
	var second_result: Dictionary = input_manager.consume_player_action("p1", ["attack"], 13)
	return second_result.is_empty()

func _test_hit_resolution_single_apply() -> bool:
	var service = HitResolutionServiceScript.new()
	service.reset_attack_registry()

	var attacker_state := {
		"id": "p1",
		"position": Vector2(0, 0),
	}
	var defender_state := {
		"id": "p2",
		"position": Vector2(24, 0),
		"hp": 1000,
		"hitstun_frames": 0,
		"hurtbox": {
			"offset": Vector2(0, 0),
			"size": Vector2(40, 80),
		},
	}
	var attack_data := {
		"damage": 120,
		"hitstun_frames": 18,
		"hitbox": {
			"offset": Vector2(10, 0),
			"size": Vector2(40, 40),
		},
	}

	var result: Dictionary = service.apply_attack(attacker_state, defender_state, attack_data, "test-attack")
	return bool(result.get("hit", false)) and int(defender_state.get("hp", -1)) == 880

func _test_round_timeout_tie_behavior() -> bool:
	var manager = RoundManagerScript.new({
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	})
	manager.set_hp_for_test(500, 500)
	manager.tick_seconds(60.0)
	return str(manager.last_event) == "round_restarted_on_tie"
