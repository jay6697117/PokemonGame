extends Node

const MatchHudModelScript := preload("res://scripts/match/match_hud_model.gd")

var model = MatchHudModelScript.new()

func update_from_round_manager(round_manager: RefCounted) -> void:
	if round_manager == null:
		return
	if not round_manager.has_method("get_hud_snapshot"):
		return
	var snapshot: Dictionary = round_manager.call("get_hud_snapshot")
	model.sync_from_snapshot(snapshot)
