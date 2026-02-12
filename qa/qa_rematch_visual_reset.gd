extends SceneTree

const HIT_EVENTS := 3
const POSITION_DRIFT := Vector2(30.0, -18.0)
const SCALE_DRIFT_FIGHTER := Vector2(1.28, 0.86)
const SCALE_DRIFT_VFX := Vector2(0.76, 1.31)
const COLOR_DRIFT := Color(1.0, 0.2, 1.0, 1.0)
const INTRO_SETTLE_SECONDS := 1.7

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle_scene = load("res://scenes/battle.tscn")
	if battle_scene == null:
		_fail("Unable to load battle.tscn")
		return

	var battle = battle_scene.instantiate()
	get_root().add_child(battle)

	var fighter_layer := battle.get_node_or_null("FighterLayer") as Control
	var vfx_layer := battle.get_node_or_null("VfxLayer") as Control
	var hit_stop_overlay := battle.get_node_or_null("OverlayLayer/HitStopOverlayCue") as ColorRect
	var arena_p1 = battle.get("_arena_p1")

	if fighter_layer == null or vfx_layer == null:
		_fail("Missing required battle layers for rematch visual reset QA", battle)
		return
	if hit_stop_overlay == null:
		_fail("Missing HitStopOverlayCue", battle)
		return
	if arena_p1 == null:
		_fail("Missing _arena_p1 reference", battle)
		return

	var body := arena_p1.get_node_or_null("Body") as ColorRect
	if body == null:
		_fail("Fighter body node missing", battle)
		return

	var rest_body_color := body.color

	for _i in HIT_EVENTS:
		battle.call("_apply_damage_to", "p2", 25)

	fighter_layer.position += POSITION_DRIFT
	vfx_layer.position -= POSITION_DRIFT
	fighter_layer.scale = SCALE_DRIFT_FIGHTER
	vfx_layer.scale = SCALE_DRIFT_VFX
	hit_stop_overlay.modulate.a = 0.95
	body.color = COLOR_DRIFT

	battle.call("_reset_match")

	var active_vfx_nodes_after_reset := _count_active_hit_sparks(vfx_layer)
	if active_vfx_nodes_after_reset != 0:
		_fail("Active hit spark nodes remain after reset: %d" % active_vfx_nodes_after_reset, battle)
		return

	if not _is_near_vec2(fighter_layer.position, Vector2.ZERO) or not _is_near_vec2(vfx_layer.position, Vector2.ZERO):
		_fail("Layer position drift not reset", battle)
		return

	if not _is_near_vec2(fighter_layer.scale, Vector2.ONE) or not _is_near_vec2(vfx_layer.scale, Vector2.ONE):
		_fail("Layer zoom drift not reset", battle)
		return

	if not is_zero_approx(hit_stop_overlay.modulate.a):
		_fail("Hit-stop overlay alpha not reset: %.3f" % hit_stop_overlay.modulate.a, battle)
		return

	if not _is_near_vec2(arena_p1.scale, Vector2.ONE):
		_fail("Fighter temporary scale state not reset", battle)
		return

	if not _is_near_color(body.color, rest_body_color):
		_fail("Fighter temporary color state not reset", battle)
		return

	await create_timer(INTRO_SETTLE_SECONDS).timeout

	print("QA_REMATCH_VISUAL_RESET_OK")
	print("ACTIVE_VFX_NODES_AFTER_RESET:%d" % active_vfx_nodes_after_reset)
	battle.free()
	await process_frame
	quit(0)

func _count_active_hit_sparks(vfx_layer: Control) -> int:
	var active_count := 0
	for child in vfx_layer.get_children():
		if child is CanvasItem and str(child.name).begins_with("HitSpark_") and not child.is_queued_for_deletion():
			active_count += 1
	return active_count

func _is_near_vec2(a: Vector2, b: Vector2) -> bool:
	return is_equal_approx(a.x, b.x) and is_equal_approx(a.y, b.y)

func _is_near_color(a: Color, b: Color) -> bool:
	return is_equal_approx(a.r, b.r) and is_equal_approx(a.g, b.g) and is_equal_approx(a.b, b.b) and is_equal_approx(a.a, b.a)

func _fail(message: String, battle: Node = null) -> void:
	printerr(message)
	if battle != null:
		battle.free()
	quit(1)
