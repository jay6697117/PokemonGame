extends SceneTree

const RosterLoaderScript := preload("res://scripts/roster/roster_loader.gd")
const CharacterSelectStateScript := preload("res://scripts/roster/character_select_state.gd")

func _init() -> void:
	var loader = RosterLoaderScript.new()
	var roster_result: Dictionary = loader.load_roster("res://data/roster.json")
	if not bool(roster_result.get("ok", false)):
		printerr("Roster load failed: %s" % str(roster_result.get("error_code", "UNKNOWN")))
		quit(1)
		return

	var fighters: Array = roster_result.get("fighters", [])
	if fighters.size() != 2:
		printerr("Expected roster size 2, got %d" % fighters.size())
		quit(1)
		return

	var allow_mirror := bool(roster_result.get("allow_mirror_selection", false))
	if not allow_mirror:
		printerr("Expected mirror selection to be allowed")
		quit(1)
		return

	var selection_state = CharacterSelectStateScript.new(allow_mirror)
	var first_fighter_id := str((fighters[0] as Dictionary).get("id", ""))

	var p1_select_result: Dictionary = selection_state.select_player("p1", first_fighter_id)
	var p2_select_result: Dictionary = selection_state.select_player("p2", first_fighter_id)
	if not bool(p1_select_result.get("ok", false)) or not bool(p2_select_result.get("ok", false)):
		printerr("Mirror selection should be accepted")
		quit(1)
		return

	print("QA_ROSTER_SCHEMA_OK")
	print("ROSTER_COUNT:%d" % fighters.size())
	print("MIRROR_SELECTION_ALLOWED:true")
	quit(0)
