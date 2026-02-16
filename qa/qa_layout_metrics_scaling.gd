extends SceneTree

const BASE_SIZE := Vector2(1280.0, 720.0)
const WIDE_SIZE := Vector2(1920.0, 1080.0)
const RATIO_EPSILON := 0.02
const INTRO_SETTLE_SECONDS := 1.7

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle_scene := load("res://scenes/battle.tscn")
	if battle_scene == null:
		_fail("Unable to load battle.tscn")
		return

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	if not battle.has_method("_compute_layout_metrics"):
		_fail("MISSING_LAYOUT_METRICS_HELPER", battle)
		return
	if not battle.has_method("_apply_layout_to_runtime_layers"):
		_fail("MISSING_RUNTIME_LAYOUT_APPLIER", battle)
		return

	var base_metrics = battle.call("_compute_layout_metrics", BASE_SIZE)
	var wide_metrics = battle.call("_compute_layout_metrics", WIDE_SIZE)

	if not (base_metrics is Dictionary) or not (wide_metrics is Dictionary):
		_fail("LAYOUT_METRICS_NOT_DICTIONARY", battle)
		return

	var required_keys := [
		"p1_spawn_x",
		"p2_spawn_x",
		"p1_min_x",
		"p1_max_x",
		"p2_min_x",
		"p2_max_x",
		"center_y",
		"half_height",
	]

	for key in required_keys:
		if not base_metrics.has(key) or not wide_metrics.has(key):
			_fail("LAYOUT_METRICS_MISSING_KEY:%s" % key, battle)
			return

	var width_ratio := WIDE_SIZE.x / BASE_SIZE.x
	var p1_ratio := _safe_ratio(float(wide_metrics["p1_spawn_x"]), float(base_metrics["p1_spawn_x"]))
	var p2_ratio := _safe_ratio(float(wide_metrics["p2_spawn_x"]), float(base_metrics["p2_spawn_x"]))
	if absf(p1_ratio - width_ratio) > RATIO_EPSILON or absf(p2_ratio - width_ratio) > RATIO_EPSILON:
		_fail("LAYOUT_METRICS_RATIO_MISMATCH p1=%.3f p2=%.3f expected=%.3f" % [p1_ratio, p2_ratio, width_ratio], battle)
		return

	if not (float(wide_metrics["p1_min_x"]) < float(wide_metrics["p1_max_x"])):
		_fail("INVALID_P1_BOUNDS", battle)
		return
	if not (float(wide_metrics["p2_min_x"]) < float(wide_metrics["p2_max_x"])):
		_fail("INVALID_P2_BOUNDS", battle)
		return

	battle.set("_layout_metrics", wide_metrics)
	battle.call("_apply_layout_to_runtime_layers")

	var arena_p1 = battle.get("_arena_p1") as Node2D
	var arena_p2 = battle.get("_arena_p2") as Node2D
	if arena_p1 == null or arena_p2 == null:
		_fail("RUNTIME_FIGHTER_BINDING_MISSING", battle)
		return

	if arena_p1.position.x < float(wide_metrics["p1_min_x"]) or arena_p1.position.x > float(wide_metrics["p1_max_x"]):
		_fail("RUNTIME_P1_OOB", battle)
		return
	if arena_p2.position.x < float(wide_metrics["p2_min_x"]) or arena_p2.position.x > float(wide_metrics["p2_max_x"]):
		_fail("RUNTIME_P2_OOB", battle)
		return

	if absf(arena_p1.position.y - float(wide_metrics["center_y"])) > 0.5:
		_fail("RUNTIME_P1_CENTER_Y_MISMATCH", battle)
		return
	if absf(arena_p2.position.y - float(wide_metrics["center_y"])) > 0.5:
		_fail("RUNTIME_P2_CENTER_Y_MISMATCH", battle)
		return

	var particles := battle.get_node_or_null("VfxLayer/AtmosphereParticles") as CPUParticles2D
	if particles == null:
		_fail("RUNTIME_PARTICLES_MISSING", battle)
		return

	var expected_center: Vector2 = wide_metrics.get("banner_pivot", WIDE_SIZE * 0.5)
	if particles.position.distance_to(expected_center) > 0.5:
		_fail("RUNTIME_PARTICLE_CENTER_MISMATCH", battle)
		return

	await create_timer(INTRO_SETTLE_SECONDS).timeout

	print("QA_LAYOUT_METRICS_SCALING_OK")
	battle.queue_free()
	await process_frame
	await process_frame
	await process_frame
	quit(0)

func _safe_ratio(numerator: float, denominator: float) -> float:
	if is_zero_approx(denominator):
		return 0.0
	return numerator / denominator

func _fail(message: String, battle: Node = null) -> void:
	printerr(message)
	if battle != null:
		battle.free()
	quit(1)
