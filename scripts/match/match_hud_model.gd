extends RefCounted
class_name MatchHudModel

var p1_hp := 0
var p2_hp := 0
var p1_rounds := 0
var p2_rounds := 0
var timer_remaining := 0.0
var current_round := 1

func sync_from_snapshot(snapshot: Dictionary) -> void:
	p1_hp = int(snapshot.get("p1_hp", p1_hp))
	p2_hp = int(snapshot.get("p2_hp", p2_hp))
	p1_rounds = int(snapshot.get("p1_rounds", p1_rounds))
	p2_rounds = int(snapshot.get("p2_rounds", p2_rounds))
	timer_remaining = float(snapshot.get("timer_remaining", timer_remaining))
	current_round = int(snapshot.get("current_round", current_round))
