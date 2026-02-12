extends Control

const AnimeArenaTheme := preload("res://scripts/theme/anime_arena_theme.gd")
const FighterVisual := preload("res://scripts/visuals/fighter_visual.gd")
const FighterVisualScene := preload("res://scripts/visuals/fighter_visual.tscn")
const ArenaAtmosphereScript := preload("res://scripts/visuals/arena_atmosphere.gd")
const HitFeedbackPipelineScript := preload("res://scripts/visuals/hit_feedback_pipeline.gd")

const START_HP := 1000
const ROUND_TIME_LIMIT := 60.0
const INTRO_ROUND_TEXT := "ROUND 1"

var p1_hp := START_HP
var p2_hp := START_HP
var _is_match_over := false
var _fight_enabled := false
var _round_time_left := ROUND_TIME_LIMIT
var _intro_ticket := 0

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
	for layer in [$BackgroundLayer, $FighterLayer, $VfxLayer, $HudLayer, $OverlayLayer]:
		for child in layer.get_children():
			child.queue_free()

	# Initialize Atmosphere
	_arena_atmosphere = ArenaAtmosphereScript.new()
	_arena_atmosphere.name = "ArenaAtmosphere"
	add_child(_arena_atmosphere)
	_arena_atmosphere.setup($BackgroundLayer, $FighterLayer, $VfxLayer)

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

	var arena_spacer := Control.new()
	arena_spacer.custom_minimum_size = Vector2(0, 360)
	arena_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(arena_spacer)

	var arena_overlay := Control.new()
	# Match original arena geometry so fighter coordinates remain valid
	arena_overlay.anchor_top = 0.5
	arena_overlay.anchor_bottom = 0.5
	arena_overlay.anchor_left = 0.0
	arena_overlay.anchor_right = 1.0
	arena_overlay.offset_top = -180
	arena_overlay.offset_bottom = 180
	
	# Add to FighterLayer but keep on top of floor (which is index 0)
	$FighterLayer.add_child(arena_overlay)

	# Instantiate Fighters
	var is_mirror = (_p1_id == _p2_id)
	
	_arena_p1 = FighterVisualScene.instantiate()
	_arena_p1.setup(_p1_id, is_mirror, false)
	# Original rect (180, 180) size (90, 140). Visual pivot at (45, 140) of rect = bottom-center
	# So pos = (180 + 45, 180 + 140) = (225, 320)
	_arena_p1.position = Vector2(225, 320)
	# Facing right by default
	_arena_p1.scale.x = abs(_arena_p1.scale.x)
	arena_overlay.add_child(_arena_p1)
	if _arena_p1.has_method("capture_rest_scale"):
		_arena_p1.call("capture_rest_scale")

	_arena_p2 = FighterVisualScene.instantiate()
	_arena_p2.setup(_p2_id, is_mirror, true)
	# Original rect (900, 180) size (90, 140).
	# Pos = (900 + 45, 180 + 140) = (945, 320)
	_arena_p2.position = Vector2(945, 320)
	# Facing left
	_arena_p2.scale.x = -abs(_arena_p2.scale.x)
	arena_overlay.add_child(_arena_p2)
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
	_center_banner.pivot_offset = Vector2(640, 360) # Approx center for 1280x720, should verify resolution
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

	# Movement constraints adjusted for pivot (center)
	# Original: min 40, max 520 (width 90, so right edge 610)
	# Pivot is +45 from left. So min X = 40 + 45 = 85.
	# Max X = 520 + 45 = 565.
	if event.is_action_pressed("p1_left"):
		_arena_p1.position.x = maxf(_arena_p1.position.x - 24.0, 85.0)
	elif event.is_action_pressed("p1_right"):
		_arena_p1.position.x = minf(_arena_p1.position.x + 24.0, 565.0)
	# P2 Original: min 620, max 1080.
	# Pivot min X = 620 + 45 = 665.
	# Pivot max X = 1080 + 45 = 1125.
	elif event.is_action_pressed("p2_left"):
		_arena_p2.position.x = maxf(_arena_p2.position.x - 24.0, 665.0)
	elif event.is_action_pressed("p2_right"):
		_arena_p2.position.x = minf(_arena_p2.position.x + 24.0, 1125.0)
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

	_is_match_over = true
	_fight_enabled = false

	# Show K.O.
	_show_banner("K.O.", AnimeArenaTheme.COLOR_BANNER_KO)
	await get_tree().create_timer(1.5).timeout
	_hide_banner()
	await get_tree().create_timer(0.2).timeout

	if p1_hp <= 0 and p2_hp <= 0:
		_finish_match("Double KO! Press Rematch", "DOUBLE KO", AnimeArenaTheme.COLOR_DOUBLE_KO)
		return

	if p1_hp <= 0:
		_finish_match("%s Wins! Press Rematch" % _p2_name, "%s WINS" % _p2_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P2)
	else:
		_finish_match("%s Wins! Press Rematch" % _p1_name, "%s WINS" % _p1_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P1)

func _on_rematch_pressed() -> void:
	_reset_match()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset_hit_feedback_presentation_state() -> void:
	if _hit_feedback_pipeline != null and _hit_feedback_pipeline.has_method("reset_temporary_state"):
		_hit_feedback_pipeline.call("reset_temporary_state")

	for fighter in [_arena_p1, _arena_p2]:
		if fighter != null and fighter.has_method("reset_temporary_feedback_state"):
			fighter.call("reset_temporary_feedback_state")

func _reset_match() -> void:
	p1_hp = START_HP
	p2_hp = START_HP
	_is_match_over = false
	_fight_enabled = false
	_round_time_left = ROUND_TIME_LIMIT
	_hide_banner()
	_reset_hit_feedback_presentation_state()
	_arena_p1.position = Vector2(225, 320)
	_arena_p2.position = Vector2(945, 320)
	_arena_p1.scale = Vector2(abs(_arena_p1.scale.x), 1.0)
	_arena_p2.scale = Vector2(-abs(_arena_p2.scale.x), 1.0)
	if _arena_p1.has_method("capture_rest_scale"):
		_arena_p1.call("capture_rest_scale")
	if _arena_p2.has_method("capture_rest_scale"):
		_arena_p2.call("capture_rest_scale")
	_status_label.text = "Get Ready"
	_update_hud()
	_start_intro_sequence()

func _update_hud() -> void:
	_p1_label.text = "%s  HP: %d" % [_p1_name, p1_hp]
	_p2_label.text = "%s  HP: %d" % [_p2_name, p2_hp]
	_p1_bar.value = p1_hp
	_p2_bar.value = p2_hp
	_timer_label.text = "Time: %02d" % int(ceil(_round_time_left))

func _start_intro_sequence() -> void:
	_intro_ticket += 1
	var current_ticket := _intro_ticket
	_show_banner(INTRO_ROUND_TEXT, AnimeArenaTheme.COLOR_BANNER_ROUND)
	await get_tree().create_timer(0.85).timeout
	if current_ticket != _intro_ticket:
		return

	_show_banner("FIGHT!", AnimeArenaTheme.COLOR_BANNER_FIGHT)
	await get_tree().create_timer(0.65).timeout
	if current_ticket != _intro_ticket:
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
	_center_banner.pivot_offset = _center_banner.size / 2
	_center_banner.scale = AnimeArenaTheme.BANNER_ANIM_SCALE_START
	_center_banner.modulate.a = 0.0
	
	_banner_bg.visible = true
	_banner_bg.pivot_offset = _banner_bg.size / 2
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
	_is_match_over = true
	_fight_enabled = false

	# Show Time Up
	_show_banner("TIME UP", AnimeArenaTheme.COLOR_BANNER_TIME_UP)
	await get_tree().create_timer(1.5).timeout
	_hide_banner()
	await get_tree().create_timer(0.2).timeout

	if p1_hp == p2_hp:
		_finish_match("Time Up - Draw", "DRAW", AnimeArenaTheme.COLOR_DRAW)
		return

	if p1_hp > p2_hp:
		_finish_match("%s Wins by Time!" % _p1_name, "%s WINS" % _p1_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P1)
		return

	_finish_match("%s Wins by Time!" % _p2_name, "%s WINS" % _p2_name.to_upper(), AnimeArenaTheme.COLOR_WIN_P2)

func _finish_match(status_text: String, banner_text: String, banner_color: Color) -> void:
	_is_match_over = true
	_fight_enabled = false
	_status_label.text = status_text
	_show_banner(banner_text, banner_color)

func _flash_target(target: FighterVisual) -> void:
	if _hit_feedback_pipeline != null and _hit_feedback_pipeline.has_method("play_hit_feedback"):
		_hit_feedback_pipeline.call("play_hit_feedback", target)
		return
	target.flash(AnimeArenaTheme.COLOR_HIT_FLASH, 0.18)
