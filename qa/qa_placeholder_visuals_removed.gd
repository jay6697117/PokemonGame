extends SceneTree

const BATTLE_SCRIPT_PATH := "res://scripts/flow/battle_screen.gd"
const PLACEHOLDER_KEYWORD := "placeholder"

func _init() -> void:
	if not FileAccess.file_exists(BATTLE_SCRIPT_PATH):
		_fail("Missing battle script: %s" % BATTLE_SCRIPT_PATH)
		return

	var battle_file := FileAccess.open(BATTLE_SCRIPT_PATH, FileAccess.READ)
	if battle_file == null:
		_fail("Unable to read battle_screen.gd")
		return

	var battle_source := battle_file.get_as_text()
	battle_file.close()

	var placeholder_references := battle_source.to_lower().count(PLACEHOLDER_KEYWORD)
	if placeholder_references != 0:
		_fail("LEGACY_PLACEHOLDER_REFERENCES:%d" % placeholder_references)
		return

	var battle_scene := load("res://scenes/battle.tscn")
	if battle_scene == null:
		_fail("Unable to load battle.tscn")
		return

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	if not battle.has_method("_build_ui"):
		_fail_with_battle("battle_screen.gd missing _build_ui", battle)
		return
	battle.call("_build_ui")

	var arena_p1 = battle.get("_arena_p1")
	var arena_p2 = battle.get("_arena_p2")
	if not _is_fighter_visual_binding_valid(arena_p1) or not _is_fighter_visual_binding_valid(arena_p2):
		_fail_with_battle("Arena fighter slots still use placeholder visuals", battle)
		return

	print("LEGACY_PLACEHOLDER_REFERENCES:0")
	print("FIGHTER_VISUAL_BINDINGS_OK:true")
	print("QA_PLACEHOLDER_VISUALS_REMOVED_OK")

	battle.free()
	quit(0)

func _is_fighter_visual_binding_valid(node) -> bool:
	if node == null:
		return false
	if node is ColorRect:
		return false
	return node is Node2D and node.has_method("setup") and node.has_method("reset_temporary_feedback_state")

func _fail(message: String) -> void:
	printerr(message)
	quit(1)

func _fail_with_battle(message: String, battle: Node) -> void:
	printerr(message)
	if battle != null:
		battle.free()
	quit(1)
