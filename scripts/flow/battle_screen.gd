extends Control

const AnimeArenaTheme := preload("res://scripts/theme/anime_arena_theme.gd")
const FighterVisual := preload("res://scripts/visuals/fighter_visual.gd")
const FighterVisualScene := preload("res://scripts/visuals/fighter_visual.tscn")
const ArenaAtmosphereScript := preload("res://scripts/visuals/arena_atmosphere.gd")
const HitFeedbackPipelineScript := preload("res://scripts/visuals/hit_feedback_pipeline.gd")

const START_HP := 1000
const ROUND_TIME_LIMIT := 60.0
const INTRO_ROUND_TEXT := "ROUND 1"

const BASE_VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const ARENA_HALF_HEIGHT_RATIO := 180.0 / 720.0
const ARENA_CENTER_Y_RATIO := 320.0 / 720.0
const ARENA_SPACER_HEIGHT_RATIO := 360.0 / 720.0
const P1_SPAWN_X_RATIO := 225.0 / 1280.0
const P2_SPAWN_X_RATIO := 945.0 / 1280.0
const P1_MIN_X_RATIO := 85.0 / 1280.0
const P1_MAX_X_RATIO := 565.0 / 1280.0
const P2_MIN_X_RATIO := 665.0 / 1280.0
const P2_MAX_X_RATIO := 1125.0 / 1280.0
const MOVE_STEP_RATIO := 24.0 / 1280.0

var p1_hp := START_HP
var p2_hp := START_HP
var _is_match_over := false
var _fight_enabled := false
var _round_time_left := ROUND_TIME_LIMIT
var _sequence_ticket := 0
var _layout_metrics: Dictionary = {}

var _p1_name := "P1"
var _p2_name := "P2"
var _p1_id := "volt_rodent"
var _p2_id := "tide_turtle"

var _p1_label: Label
var _p2_label: Label
var _p1_bar: ProgressBar
var _p2_bar: ProgressBar
var _status_label: Label
var _timer_label: Label
var _arena_p1: FighterVisual
var _arena_p2: FighterVisual
var _arena_atmosphere: Node
var _hit_feedback_pipeline: Node
var _action_hint: Label
var _center_banner: Label
var _banner_bg: ColorRect
var _banner_tween: Tween
var _arena_spacer: Control
var _arena_overlay: Control

func _ready() -> void:
	_load_fighter_data()
	_build_ui()
	_reset_match()

func _load_fighter_data() -> void:
	var session := get_node_or_null("/root/GameSession")
	if session == null:
		return

	if session.has_method("get_p1_display_name"):
		_p1_name = str(session.call("get_p1_display_name"))
	if session.has_method("get_p2_display_name"):
		_p2_name = str(session.call("get_p2_display_name"))
		
	# Get IDs directly if property exists
	if "p1_fighter_id" in session:
		_p1_id = session.p1_fighter_id
	if "p2_fighter_id" in session:
		_p2_id = session.p2_fighter_id

func _build_ui() -> void:
	_refresh_layout_metrics()

	if _arena_atmosphere != null and is_instance_valid(_arena_atmosphere):
		_arena_atmosphere.queue_free()
		_arena_atmosphere = null

	for layer in [$BackgroundLayer, $FighterLayer, $VfxLayer, $HudLayer, $OverlayLayer]:
		for child in layer.get_children():
			child.queue_free()

	# Initialize Atmosphere
	_arena_atmosphere = ArenaAtmosphereScript.new()
	_arena_atmosphere.name = "ArenaAtmosphere"
	add_child(_arena_atmosphere)
	_arena_atmosphere.setup($BackgroundLayer, $FighterLayer, $VfxLayer, _layout_metrics)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", AnimeArenaTheme.MARGIN_OUTER_X)
	root_margin.add_theme_constant_override("margin_top", AnimeArenaTheme.MARGIN_OUTER_Y)
	root_margin.add_theme_constant_override("margin_right", AnimeArenaTheme.MARGIN_OUTER_X)
	root_margin.add_theme_constant_override("margin_bottom", AnimeArenaTheme.MARGIN_OUTER_Y)
	$HudLayer.add_child(root_margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", AnimeArenaTheme.SPACING_MAIN_V)
	root_margin.add_child(root)

	var title := Label.new()
	title.text = "Battle Arena"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", AnimeArenaTheme.FONT_SIZE_TITLE)
	root.add_child(title)

	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", AnimeArenaTheme.SPACING_BARS_H)
	bars.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(bars)

	var p1_box := VBoxContainer.new()
	p1_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_child(p1_box)
	_p1_label = Label.new()
	_p1_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	p1_box.add_child(_p1_label)
	_p1_bar = ProgressBar.new()
	_p1_bar.max_value = START_HP
	_p1_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p1_box.add_child(_p1_bar)

	var p2_box := VBoxContainer.new()
	p2_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_child(p2_box)
	_p2_label = Label.new()
	_p2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_box.add_child(_p2_label)
	_p2_bar = ProgressBar.new()
	_p2_bar.max_value = START_HP
	_p2_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p2_box.add_child(_p2_bar)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", AnimeArenaTheme.FONT_SIZE_HUD_LABEL)
	root.add_child(_status_label)

	_timer_label = Label.new()
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", AnimeArenaTheme.FONT_SIZE_HUD_LABEL)
	root.add_child(_timer_label)

	_arena_spacer = Control.new()
	_arena_spacer.custom_minimum_size = Vector2(0, _layout_metrics.get("spacer_height", BASE_VIEWPORT_SIZE.y * ARENA_SPACER_HEIGHT_RATIO))
	_arena_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_arena_spacer)

	_arena_overlay = Control.new()
	_arena_overlay.anchor_top = 0.5
	_arena_overlay.anchor_bottom = 0.5
	_arena_overlay.anchor_left = 0.0
	_arena_overlay.anchor_right = 1.0
	_arena_overlay.offset_top = -float(_layout_metrics.get("half_height", BASE_VIEWPORT_SIZE.y * ARENA_HALF_HEIGHT_RATIO))
	_arena_overlay.offset_bottom = float(_layout_metrics.get("half_height", BASE_VIEWPORT_SIZE.y * ARENA_HALF_HEIGHT_RATIO))
	
	# Add to FighterLayer but keep on top of floor (which is index 0)
	$FighterLayer.add_child(_arena_overlay)

	# Instantiate Fighters
	var is_mirror = (_p1_id == _p2_id)
	
	_arena_p1 = FighterVisualScene.instantiate()
	_arena_p1.setup(_p1_id, is_mirror, false)
	_arena_p1.position = Vector2(
		float(_layout_metrics.get("p1_spawn_x", 225.0)),
		float(_layout_metrics.get("center_y", 320.0))
	)
	# Facing right by default
	_arena_p1.scale.x = abs(_arena_p1.scale.x)
	_arena_overlay.add_child(_arena_p1)
	if _arena_p1.has_method("capture_rest_scale"):
		_arena_p1.call("capture_rest_scale")

	_arena_p2 = FighterVisualScene.instantiate()
	_arena_p2.setup(_p2_id, is_mirror, true)
	_arena_p2.position = Vector2(
		float(_layout_metrics.get("p2_spawn_x", 945.0)),
		float(_layout_metrics.get("center_y", 320.0))
	)
	# Facing left
	_arena_p2.scale.x = -abs(_arena_p2.scale.x)
	_arena_overlay.add_child(_arena_p2)
	if _arena_p2.has_method("capture_rest_scale"):
		_arena_p2.call("capture_rest_scale")

	var existing_feedback_pipeline := get_node_or_null("HitFeedbackPipeline")
	if existing_feedback_pipeline != null:
		existing_feedback_pipeline.free()

	_hit_feedback_pipeline = HitFeedbackPipelineScript.new()
	_hit_feedback_pipeline.name = "HitFeedbackPipeline"
	add_child(_hit_feedback_pipeline)
	_hit_feedback_pipeline.call("setup", $FighterLayer, $VfxLayer, $OverlayLayer)

	_action_hint = Label.new()
	_action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_hint.text = "P1: A/D move, F light, G heavy | P2: J/L move, U light, O heavy"
	root.add_child(_action_hint)

	var action_buttons := HBoxContainer.new()
	action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	action_buttons.add_theme_constant_override("separation", AnimeArenaTheme.SPACING_MAIN_V)
	root.add_child(action_buttons)

	var rematch_button := Button.new()
	rematch_button.text = "Rematch"
	rematch_button.custom_minimum_size = Vector2(180, 44)
	rematch_button.pressed.connect(_on_rematch_pressed)
	action_buttons.add_child(rematch_button)

	var back_button := Button.new()
	back_button.text = "Back to Main Menu"
	back_button.custom_minimum_size = Vector2(220, 44)
	back_button.pressed.connect(_on_back_pressed)
	action_buttons.add_child(back_button)

	_banner_bg = ColorRect.new()
	_banner_bg.visible = false
	_banner_bg.color = Color(0, 0, 0, 0.7)
	_banner_bg.custom_minimum_size = Vector2(0, 160)
	_banner_bg.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_banner_bg.anchor_left = 0.0
	_banner_bg.anchor_right = 1.0
	_banner_bg.pivot_offset = Vector2(0, 80) # Center pivot for scaling Y
	$OverlayLayer.add_child(_banner_bg)

	_center_banner = Label.new()
	_center_banner.visible = false
	_center_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center_banner.add_theme_font_size_override("font_size", AnimeArenaTheme.FONT_SIZE_BANNER_LARGE)
	_center_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	_center_banner.add_theme_constant_override("outline_size", 12)
	_center_banner.add_theme_constant_override("shadow_offset_x", 4)
	_center_banner.add_theme_constant_override("shadow_offset_y", 4)
	_center_banner.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	_center_banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_center_banner.pivot_offset = _layout_metrics.get("banner_pivot", BASE_VIEWPORT_SIZE * 0.5)
	_center_banner.z_index = 10
	$OverlayLayer.add_child(_center_banner)

	set_process(true)

func _process(delta: float) -> void:
	if _is_match_over:
		return
	if not _fight_enabled:
		return

	_round_time_left = maxf(_round_time_left - delta, 0.0)
	_timer_label.text = "Time: %02d" % int(ceil(_round_time_left))
	if _round_time_left <= 0.0:
		_resolve_timeout()

func _unhandled_input(event: InputEvent) -> void:
	if _is_match_over:
		return
	if not _fight_enabled:
		return

	var move_step := float(_layout_metrics.get("move_step", 24.0))
	var p1_min_x := float(_layout_metrics.get("p1_min_x", 85.0))
	var p1_max_x := float(_layout_metrics.get("p1_max_x", 565.0))
	var p2_min_x := float(_layout_metrics.get("p2_min_x", 665.0))
	var p2_max_x := float(_layout_metrics.get("p2_max_x", 1125.0))

	if event.is_action_pressed("p1_left"):
		_arena_p1.position.x = maxf(_arena_p1.position.x - move_step, p1_min_x)
	elif event.is_action_pressed("p1_right"):
		_arena_p1.position.x = minf(_arena_p1.position.x + move_step, p1_max_x)
	elif event.is_action_pressed("p2_left"):
		_arena_p2.position.x = maxf(_arena_p2.position.x - move_step, p2_min_x)
	elif event.is_action_pressed("p2_right"):
		_arena_p2.position.x = minf(_arena_p2.position.x + move_step, p2_max_x)
	elif event.is_action_pressed("p1_light"):
		_apply_damage_to("p2", 45)
	elif event.is_action_pressed("p1_heavy"):
		_apply_damage_to("p2", 90)
	elif event.is_action_pressed("p2_light"):
		_apply_damage_to("p1", 45)
	elif event.is_action_pressed("p2_heavy"):
		_apply_damage_to("p1", 90)

func _apply_damage_to(target: String, damage: int) -> void:
	if target == "p1":
		p1_hp = maxi(p1_hp - damage, 0)
		_flash_target(_arena_p1)
	else:
		p2_hp = maxi(p2_hp - damage, 0)
		_flash_target(_arena_p2)

	_update_hud()
	_check_ko()

func _check_ko() -> void:
	if p1_hp > 0 and p2_hp > 0:
		return

	var sequence_ticket := _begin_sequence()
	_is_match_over = true
	_fight_enabled = false

	# Show K.O.
	_show_banner("K.O.", AnimeArenaTheme.COLOR_BANNER_KO)
	await get_tree().create_timer(1.5).timeout
	if not _is_sequence_active(sequence_ticket):
		return
	_hide_banner()
	await get_tree().create_timer(0.2).timeout
	if not _is_sequence_active(sequence_ticket):
		return

	if p1_hp <= 0 and p2_hp <= 0:
		_finish_match("Double KO! Press Rematch", "DOUBLE KO", AnimeArenaTheme.COLOR_DOUBLE_KO, sequence_ticket)
		return

	if p1_hp <= 0:
		_finish_match("%s Wins! Press Rematch" % _p2_name, "%s WINS" % _p2_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P2, sequence_ticket)
	else:
		_finish_match("%s Wins! Press Rematch" % _p1_name, "%s WINS" % _p1_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P1, sequence_ticket)

func _on_rematch_pressed() -> void:
	_reset_match()

func _on_back_pressed() -> void:
	_begin_sequence()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset_hit_feedback_presentation_state() -> void:
	if _hit_feedback_pipeline != null and _hit_feedback_pipeline.has_method("reset_temporary_state"):
		_hit_feedback_pipeline.call("reset_temporary_state")

	for fighter in [_arena_p1, _arena_p2]:
		if fighter != null and fighter.has_method("reset_temporary_feedback_state"):
			fighter.call("reset_temporary_feedback_state")

func _reset_match() -> void:
	var sequence_ticket := _begin_sequence()
	_refresh_layout_metrics()
	_apply_layout_to_runtime_layers()

	p1_hp = START_HP
	p2_hp = START_HP
	_is_match_over = false
	_fight_enabled = false
	_round_time_left = ROUND_TIME_LIMIT
	_hide_banner()
	_reset_hit_feedback_presentation_state()
	_arena_p1.position = Vector2(
		float(_layout_metrics.get("p1_spawn_x", 225.0)),
		float(_layout_metrics.get("center_y", 320.0))
	)
	_arena_p2.position = Vector2(
		float(_layout_metrics.get("p2_spawn_x", 945.0)),
		float(_layout_metrics.get("center_y", 320.0))
	)
	_arena_p1.scale = Vector2(abs(_arena_p1.scale.x), abs(_arena_p1.scale.y))
	_arena_p2.scale = Vector2(-abs(_arena_p2.scale.x), abs(_arena_p2.scale.y))
	if _arena_p1.has_method("capture_rest_scale"):
		_arena_p1.call("capture_rest_scale")
	if _arena_p2.has_method("capture_rest_scale"):
		_arena_p2.call("capture_rest_scale")
	_status_label.text = "Get Ready"
	_update_hud()
	_start_intro_sequence(sequence_ticket)

func _update_hud() -> void:
	_p1_label.text = "%s  HP: %d" % [_p1_name, p1_hp]
	_p2_label.text = "%s  HP: %d" % [_p2_name, p2_hp]
	_p1_bar.value = p1_hp
	_p2_bar.value = p2_hp
	_timer_label.text = "Time: %02d" % int(ceil(_round_time_left))

func _start_intro_sequence(sequence_ticket: int) -> void:
	_show_banner(INTRO_ROUND_TEXT, AnimeArenaTheme.COLOR_BANNER_ROUND)
	await get_tree().create_timer(0.85).timeout
	if not _is_sequence_active(sequence_ticket):
		return

	_show_banner("FIGHT!", AnimeArenaTheme.COLOR_BANNER_FIGHT)
	await get_tree().create_timer(0.65).timeout
	if not _is_sequence_active(sequence_ticket):
		return

	_hide_banner()
	_fight_enabled = true
	_status_label.text = "Fight!"

func _hide_banner() -> void:
	if _banner_tween != null:
		_banner_tween.kill()
		_banner_tween = null
	_center_banner.scale = Vector2.ONE
	_center_banner.modulate.a = 1.0
	_center_banner.visible = false
	_banner_bg.scale = Vector2.ONE
	_banner_bg.modulate.a = 1.0
	_banner_bg.visible = false

func _show_banner(text: String, color: Color) -> void:
	if _banner_tween != null:
		_banner_tween.kill()
		_banner_tween = null

	_center_banner.text = text
	_center_banner.modulate = color
	_center_banner.visible = true
	var banner_size := _center_banner.size
	if is_zero_approx(banner_size.x) or is_zero_approx(banner_size.y):
		_center_banner.pivot_offset = _layout_metrics.get("banner_pivot", BASE_VIEWPORT_SIZE * 0.5)
	else:
		_center_banner.pivot_offset = banner_size * 0.5
	_center_banner.scale = AnimeArenaTheme.BANNER_ANIM_SCALE_START
	_center_banner.modulate.a = 0.0
	
	_banner_bg.visible = true
	var bg_size := _banner_bg.size
	if is_zero_approx(bg_size.x) or is_zero_approx(bg_size.y):
		_banner_bg.pivot_offset = Vector2(_layout_metrics.get("banner_pivot", BASE_VIEWPORT_SIZE * 0.5).x, float(_layout_metrics.get("half_height", 180.0)))
	else:
		_banner_bg.pivot_offset = bg_size * 0.5
	_banner_bg.scale.y = 0.0
	_banner_bg.modulate = Color(0, 0, 0, 0.7)

	_banner_tween = create_tween()
	_banner_tween.set_parallel(true)
	
	# Background expansion (vertical strip)
	_banner_tween.tween_property(_banner_bg, "scale:y", 1.0, AnimeArenaTheme.BANNER_ANIM_DURATION_IN * 0.8)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Text slam
	_banner_tween.tween_property(_center_banner, "scale", AnimeArenaTheme.BANNER_ANIM_SCALE_END, AnimeArenaTheme.BANNER_ANIM_DURATION_IN)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_property(_center_banner, "modulate:a", 1.0, AnimeArenaTheme.BANNER_ANIM_DURATION_IN * 0.4)


func _resolve_timeout() -> void:
	var sequence_ticket := _begin_sequence()
	_is_match_over = true
	_fight_enabled = false

	# Show Time Up
	_show_banner("TIME UP", AnimeArenaTheme.COLOR_BANNER_TIME_UP)
	await get_tree().create_timer(1.5).timeout
	if not _is_sequence_active(sequence_ticket):
		return
	_hide_banner()
	await get_tree().create_timer(0.2).timeout
	if not _is_sequence_active(sequence_ticket):
		return

	if p1_hp == p2_hp:
		_finish_match("Time Up - Draw", "DRAW", AnimeArenaTheme.COLOR_DRAW, sequence_ticket)
		return

	if p1_hp > p2_hp:
		_finish_match("%s Wins by Time!" % _p1_name, "%s WINS" % _p1_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P1, sequence_ticket)
		return

	_finish_match("%s Wins by Time!" % _p2_name, "%s WINS" % _p2_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P2, sequence_ticket)

func _finish_match(status_text: String, banner_text: String, banner_color: Color, sequence_ticket: int = -1) -> void:
	if sequence_ticket != -1 and not _is_sequence_active(sequence_ticket):
		return
	_is_match_over = true
	_fight_enabled = false
	_status_label.text = status_text
	_show_banner(banner_text, banner_color)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refresh_layout_metrics()
		_apply_layout_to_runtime_layers()

func _begin_sequence() -> int:
	_sequence_ticket += 1
	return _sequence_ticket

func _is_sequence_active(sequence_ticket: int) -> bool:
	return sequence_ticket == _sequence_ticket

func _current_viewport_size() -> Vector2:
	if not is_inside_tree():
		return BASE_VIEWPORT_SIZE
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return BASE_VIEWPORT_SIZE
	return viewport_size

func _compute_layout_metrics(viewport_size: Vector2) -> Dictionary:
	var width := maxf(viewport_size.x, 1.0)
	var height := maxf(viewport_size.y, 1.0)
	return {
		"viewport_size": Vector2(width, height),
		"center_y": height * ARENA_CENTER_Y_RATIO,
		"half_height": height * ARENA_HALF_HEIGHT_RATIO,
		"spacer_height": height * ARENA_SPACER_HEIGHT_RATIO,
		"p1_spawn_x": width * P1_SPAWN_X_RATIO,
		"p2_spawn_x": width * P2_SPAWN_X_RATIO,
		"p1_min_x": width * P1_MIN_X_RATIO,
		"p1_max_x": width * P1_MAX_X_RATIO,
		"p2_min_x": width * P2_MIN_X_RATIO,
		"p2_max_x": width * P2_MAX_X_RATIO,
		"move_step": maxf(1.0, width * MOVE_STEP_RATIO),
		"banner_pivot": Vector2(width * 0.5, height * 0.5),
	}

func _refresh_layout_metrics() -> void:
	_layout_metrics = _compute_layout_metrics(_current_viewport_size())

func _apply_layout_to_runtime_layers() -> void:
	if _layout_metrics.is_empty():
		return

	if _arena_spacer != null:
		_arena_spacer.custom_minimum_size = Vector2(0, float(_layout_metrics.get("spacer_height", BASE_VIEWPORT_SIZE.y * ARENA_SPACER_HEIGHT_RATIO)))

	if _arena_overlay != null:
		var half_height := float(_layout_metrics.get("half_height", BASE_VIEWPORT_SIZE.y * ARENA_HALF_HEIGHT_RATIO))
		_arena_overlay.offset_top = -half_height
		_arena_overlay.offset_bottom = half_height

	if _arena_p1 != null:
		_arena_p1.position = Vector2(
			clampf(_arena_p1.position.x, float(_layout_metrics.get("p1_min_x", 85.0)), float(_layout_metrics.get("p1_max_x", 565.0))),
			float(_layout_metrics.get("center_y", 320.0))
		)

	if _arena_p2 != null:
		_arena_p2.position = Vector2(
			clampf(_arena_p2.position.x, float(_layout_metrics.get("p2_min_x", 665.0)), float(_layout_metrics.get("p2_max_x", 1125.0))),
			float(_layout_metrics.get("center_y", 320.0))
		)

	if _center_banner != null:
		_center_banner.pivot_offset = _layout_metrics.get("banner_pivot", BASE_VIEWPORT_SIZE * 0.5)

	if _arena_atmosphere != null and _arena_atmosphere.has_method("apply_layout_metrics"):
		_arena_atmosphere.call("apply_layout_metrics", _layout_metrics)

func _flash_target(target: FighterVisual) -> void:
	if _hit_feedback_pipeline != null and _hit_feedback_pipeline.has_method("play_hit_feedback"):
		_hit_feedback_pipeline.call("play_hit_feedback", target)
		return
	target.flash(AnimeArenaTheme.COLOR_HIT_FLASH, 0.18)
