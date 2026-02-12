extends SceneTree

const HIT_EVENTS := 3

func _init() -> void:
	if not FileAccess.file_exists("res://scripts/visuals/hit_feedback_pipeline.gd"):
		printerr("Missing hit feedback pipeline script")
		quit(1)
		return

	var battle_file := FileAccess.open("res://scripts/flow/battle_screen.gd", FileAccess.READ)
	if battle_file == null:
		printerr("Unable to read battle_screen.gd")
		quit(1)
		return

	var battle_source := battle_file.get_as_text()
	if not "HitFeedbackPipelineScript" in battle_source:
		printerr("battle_screen.gd missing HitFeedbackPipelineScript wiring")
		quit(1)
		return
	if not "play_hit_feedback" in battle_source:
		printerr("battle_screen.gd missing play_hit_feedback hook")
		quit(1)
		return

	var battle_scene = load("res://scenes/battle.tscn")
	if battle_scene == null:
		printerr("Unable to load battle.tscn")
		quit(1)
		return

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	if not battle.has_method("_build_ui"):
		printerr("battle_screen.gd missing _build_ui")
		battle.free()
		quit(1)
		return
	battle.call("_build_ui")

	if not battle.has_method("_apply_damage_to"):
		printerr("battle_screen.gd missing _apply_damage_to")
		battle.free()
		quit(1)
		return

	for i in HIT_EVENTS:
		battle.call("_apply_damage_to", "p2", 25)

	var pipeline = battle.get_node_or_null("HitFeedbackPipeline")
	if pipeline == null:
		printerr("HitFeedbackPipeline node missing in battle scene")
		battle.free()
		quit(1)
		return

	var metrics: Dictionary = pipeline.call("get_feedback_metrics")
	var total_hits := int(metrics.get("total_hits", 0))
	var spark_count := int(metrics.get("spark_count", 0))
	var flash_count := int(metrics.get("flash_count", 0))
	var shake_count := int(metrics.get("shake_count", 0))
	var hit_stop_count := int(metrics.get("hit_stop_count", 0))

	if total_hits != HIT_EVENTS:
		printerr("Unexpected total_hits: %d" % total_hits)
		battle.free()
		quit(1)
		return
	if spark_count != HIT_EVENTS:
		printerr("Unexpected spark_count: %d" % spark_count)
		battle.free()
		quit(1)
		return
	if flash_count != HIT_EVENTS:
		printerr("Unexpected flash_count: %d" % flash_count)
		battle.free()
		quit(1)
		return
	if shake_count != HIT_EVENTS:
		printerr("Unexpected shake_count: %d" % shake_count)
		battle.free()
		quit(1)
		return
	if hit_stop_count != HIT_EVENTS:
		printerr("Unexpected hit_stop_count: %d" % hit_stop_count)
		battle.free()
		quit(1)
		return

	var ratio := float(spark_count) / float(maxi(total_hits, 1))
	print("QA_HIT_FEEDBACK_OK")
	print("HIT_TO_VFX_RATIO:%.2f" % ratio)

	battle.free()
	quit(0)
