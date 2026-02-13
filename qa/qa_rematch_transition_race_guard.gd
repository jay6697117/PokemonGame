extends SceneTree

const SETTLE_SECONDS := 2.2
const CASE_KO := "KO"
const CASE_TIMEOUT := "TIMEUP"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var ko_ok := await _run_case(CASE_KO)
	var timeout_ok := await _run_case(CASE_TIMEOUT)

	print("KO_STALE_BLOCKED:%s" % str(ko_ok).to_lower())
	print("TIMEUP_STALE_BLOCKED:%s" % str(timeout_ok).to_lower())

	if not ko_ok or not timeout_ok:
		quit(1)
		return

	print("QA_REMATCH_TRANSITION_RACE_GUARD_OK")
	quit(0)

func _run_case(case_name: String) -> bool:
	var battle_scene := load("res://scenes/battle.tscn")
	if battle_scene == null:
		_fail("%s:Unable to load battle.tscn" % case_name)
		return false

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	if case_name == CASE_KO:
		battle.set("p1_hp", 1000)
		battle.set("p2_hp", 0)
		battle.call("_check_ko")
	else:
		battle.call("_resolve_timeout")

	await create_timer(0.05).timeout
	battle.call("_reset_match")

	await create_timer(SETTLE_SECONDS).timeout

	var is_match_over := bool(battle.get("_is_match_over"))
	var fight_enabled := bool(battle.get("_fight_enabled"))
	var status_label := battle.get("_status_label") as Label
	var status_text := ""
	if status_label != null:
		status_text = status_label.text

	if is_match_over:
		_fail("%s:STALE_SEQUENCE_MATCH_OVER:true" % case_name, battle)
		return false

	if not fight_enabled:
		_fail("%s:STALE_SEQUENCE_FIGHT_ENABLED:false" % case_name, battle)
		return false

	var has_stale_terminal_status := (
		status_text.findn("WINS") != -1
		or status_text.findn("KO") != -1
		or status_text.findn("DRAW") != -1
		or status_text.findn("Time Up") != -1
	)
	if has_stale_terminal_status:
		_fail("%s:STALE_SEQUENCE_STATUS:%s" % [case_name, status_text], battle)
		return false

	battle.free()
	await process_frame
	return true

func _fail(message: String, battle: Node = null) -> void:
	printerr(message)
	if battle != null:
		battle.free()
	quit(1)
