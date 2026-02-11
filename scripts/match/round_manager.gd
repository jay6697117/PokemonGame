extends RefCounted
class_name RoundManager

const PHASE_ROUND_ACTIVE := "ROUND_ACTIVE"
const PHASE_ROUND_END := "ROUND_END"
const PHASE_MATCH_END := "MATCH_END"

var default_hp := 1000
var round_duration_seconds := 60.0
var best_of_rounds := 3
var rounds_to_win := 2

var current_round := 1
var phase := PHASE_ROUND_ACTIVE
var timer_remaining := 60.0
var scores := {
	"p1": 0,
	"p2": 0,
}
var hp := {
	"p1": 1000,
	"p2": 1000,
}
var last_event := ""
var tie_restart_count := 0

func _init(config: Dictionary = {}) -> void:
	default_hp = int(config.get("default_hp", default_hp))
	round_duration_seconds = float(config.get("round_duration_seconds", round_duration_seconds))
	best_of_rounds = int(config.get("best_of_rounds", best_of_rounds))
	rounds_to_win = int(ceil(float(best_of_rounds) / 2.0))
	start_new_match()

func start_new_match() -> void:
	current_round = 1
	phase = PHASE_ROUND_ACTIVE
	timer_remaining = round_duration_seconds
	scores["p1"] = 0
	scores["p2"] = 0
	hp["p1"] = default_hp
	hp["p2"] = default_hp
	last_event = "match_started"
	tie_restart_count = 0

func apply_damage(target_player: String, damage: int) -> void:
	if phase != PHASE_ROUND_ACTIVE:
		return
	if not hp.has(target_player):
		return

	hp[target_player] = maxi(int(hp[target_player]) - maxi(damage, 0), 0)
	if int(hp[target_player]) == 0:
		_register_round_win(_opponent_of(target_player), "ko")

func tick_seconds(delta_seconds: float) -> void:
	if phase != PHASE_ROUND_ACTIVE:
		return

	timer_remaining = maxf(timer_remaining - maxf(delta_seconds, 0.0), 0.0)
	if timer_remaining <= 0.0:
		_resolve_timeout()

func start_next_round() -> bool:
	if phase == PHASE_MATCH_END:
		return false
	if phase != PHASE_ROUND_END:
		return false

	current_round += 1
	_reset_round_state()
	last_event = "next_round_started"
	return true

func set_hp_for_test(p1_hp: int, p2_hp: int) -> void:
	hp["p1"] = maxi(p1_hp, 0)
	hp["p2"] = maxi(p2_hp, 0)

func resolve_double_ko() -> void:
	if phase != PHASE_ROUND_ACTIVE:
		return
	hp["p1"] = 0
	hp["p2"] = 0
	tie_restart_count += 1
	_reset_round_state()
	last_event = "double_ko_tie_restart"

func get_hud_snapshot() -> Dictionary:
	return {
		"p1_hp": int(hp["p1"]),
		"p2_hp": int(hp["p2"]),
		"p1_rounds": int(scores["p1"]),
		"p2_rounds": int(scores["p2"]),
		"timer_remaining": timer_remaining,
		"current_round": current_round,
		"phase": phase,
	}

func _resolve_timeout() -> void:
	var p1_hp := int(hp["p1"])
	var p2_hp := int(hp["p2"])

	if p1_hp > p2_hp:
		_register_round_win("p1", "timeout")
		return
	if p2_hp > p1_hp:
		_register_round_win("p2", "timeout")
		return

	# Tie: restart round with no score change.
	tie_restart_count += 1
	_reset_round_state()
	last_event = "round_restarted_on_tie"

func _register_round_win(winner_player: String, win_type: String) -> void:
	if not scores.has(winner_player):
		return

	scores[winner_player] = int(scores[winner_player]) + 1
	phase = PHASE_ROUND_END
	last_event = "%s_win_%s" % [winner_player, win_type]

	if int(scores[winner_player]) >= rounds_to_win:
		phase = PHASE_MATCH_END
		last_event = "%s_match_win" % winner_player

func _reset_round_state() -> void:
	phase = PHASE_ROUND_ACTIVE
	hp["p1"] = default_hp
	hp["p2"] = default_hp
	timer_remaining = round_duration_seconds

func _opponent_of(player_id: String) -> String:
	return "p2" if player_id == "p1" else "p1"
