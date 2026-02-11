extends RefCounted
class_name MatchFlowController

const RosterLoaderScript := preload("res://scripts/roster/roster_loader.gd")
const CharacterSelectStateScript := preload("res://scripts/roster/character_select_state.gd")
const RoundManagerScript := preload("res://scripts/match/round_manager.gd")
const LocalInputManagerScript := preload("res://scripts/input/local_input_manager.gd")

var phase := ""
var flow_trace: Array[String] = []
var selected_fighters := {
	"p1": "",
	"p2": "",
}

var _roster_loader = RosterLoaderScript.new()
var _selection_state = CharacterSelectStateScript.new(true)
var _roster_fighters: Array[Dictionary] = []
var _round_manager = RoundManagerScript.new(_default_match_config())
var _input_manager = LocalInputManagerScript.new(6)

func _init() -> void:
	var roster_result: Dictionary = _roster_loader.load_roster("res://data/roster.json")
	if bool(roster_result.get("ok", false)):
		var allow_mirror := bool(roster_result.get("allow_mirror_selection", true))
		_selection_state = CharacterSelectStateScript.new(allow_mirror)
		_roster_fighters = roster_result.get("fighters", [])
	_enter_phase("SELECT")

func get_available_fighter_ids() -> Array[String]:
	var ids: Array[String] = []
	for fighter_data in _roster_fighters:
		ids.append(str(fighter_data.get("id", "")))
	return ids

func select_fighter(player_id: String, fighter_id: String) -> Dictionary:
	if phase != "SELECT":
		return _error("ERR_INVALID_PHASE")

	var result: Dictionary = _selection_state.select_player(player_id, fighter_id)
	if not bool(result.get("ok", false)):
		return result

	selected_fighters[player_id] = fighter_id
	return {
		"ok": true,
		"error_code": "",
	}

func begin_fight() -> Dictionary:
	if phase != "SELECT":
		return _error("ERR_INVALID_PHASE")

	if str(selected_fighters.get("p1", "")).is_empty() or str(selected_fighters.get("p2", "")).is_empty():
		return _error("ERR_SELECTION_INCOMPLETE")

	_round_manager = RoundManagerScript.new(_default_match_config())
	_enter_phase("FIGHT")
	return {
		"ok": true,
		"error_code": "",
	}

func apply_damage(target_player: String, damage: int) -> void:
	if phase != "FIGHT":
		return

	_round_manager.apply_damage(target_player, damage)
	var snapshot: Dictionary = _round_manager.get_hud_snapshot()
	var current_phase := str(snapshot.get("phase", ""))
	if current_phase == RoundManagerScript.PHASE_ROUND_END or current_phase == RoundManagerScript.PHASE_MATCH_END:
		var winner := _winner_from_scores(snapshot)
		complete_match(winner)

func complete_match(winner_id: String) -> void:
	if phase != "FIGHT":
		return
	_enter_phase("RESULT")

func request_rematch() -> Dictionary:
	if phase != "RESULT":
		return _error("ERR_INVALID_PHASE")

	_input_manager.reset_for_rematch()
	_round_manager.start_new_match()
	_enter_phase("REMATCH")

	var snapshot: Dictionary = _round_manager.get_hud_snapshot()
	var hp_reset := int(snapshot.get("p1_hp", -1)) == 1000 and int(snapshot.get("p2_hp", -1)) == 1000
	var input_buffer_cleared := _input_manager.total_buffered_actions() == 0 and _input_manager.total_stuck_keys() == 0

	return {
		"ok": true,
		"hp_reset": hp_reset,
		"input_buffer_cleared": input_buffer_cleared,
	}

func queue_test_input(player_id: String, action_name: String, frame: int) -> void:
	_input_manager.record_player_action(player_id, action_name, frame)

func set_test_pressed(player_id: String, action_name: String, is_pressed: bool) -> void:
	_input_manager.set_player_action_pressed(player_id, action_name, is_pressed)

func get_flow_trace_string() -> String:
	return "->".join(flow_trace)

func _enter_phase(next_phase: String) -> void:
	phase = next_phase
	flow_trace.append(next_phase)

func _winner_from_scores(snapshot: Dictionary) -> String:
	var p1_score := int(snapshot.get("p1_rounds", 0))
	var p2_score := int(snapshot.get("p2_rounds", 0))
	return "p1" if p1_score >= p2_score else "p2"

func _default_match_config() -> Dictionary:
	return {
		"default_hp": 1000,
		"round_duration_seconds": 60,
		"best_of_rounds": 3,
	}

func _error(error_code: String) -> Dictionary:
	return {
		"ok": false,
		"error_code": error_code,
	}
