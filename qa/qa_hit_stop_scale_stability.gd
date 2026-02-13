extends SceneTree

const HIT_COUNT := 20
const SETTLE_SECONDS := 0.3
const SCALE_EPSILON := 0.015

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle_scene := load("res://scenes/battle.tscn")
	if battle_scene == null:
		_fail("Unable to load battle.tscn")
		return

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	var arena_p2 = battle.get("_arena_p2")
	if not (arena_p2 is Node2D):
		_fail("Missing _arena_p2 Node2D", battle)
		return

	var fighter := arena_p2 as Node2D
	var baseline_scale := fighter.scale

	for _i in HIT_COUNT:
		battle.call("_apply_damage_to", "p2", 1)

	await create_timer(SETTLE_SECONDS).timeout

	var final_scale := fighter.scale
	if not _is_near_vec2(final_scale, baseline_scale, SCALE_EPSILON):
		_fail("HIT_STOP_SCALE_DRIFT: baseline=%s final=%s" % [baseline_scale, final_scale], battle)
		return

	print("QA_HIT_STOP_SCALE_STABILITY_OK")
	battle.queue_free()
	await process_frame
	await process_frame
	quit(0)

func _is_near_vec2(a: Vector2, b: Vector2, epsilon: float) -> bool:
	return absf(a.x - b.x) <= epsilon and absf(a.y - b.y) <= epsilon

func _fail(message: String, battle: Node = null) -> void:
	printerr(message)
	if battle != null:
		battle.free()
	quit(1)
