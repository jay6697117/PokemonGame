extends Control

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

var _p1_label: Label
var _p2_label: Label
var _p1_bar: ProgressBar
var _p2_bar: ProgressBar
var _status_label: Label
var _timer_label: Label
var _arena_p1: ColorRect
var _arena_p2: ColorRect
var _action_hint: Label
var _center_banner: Label

func _ready() -> void:
	_load_fighter_names()
	_build_ui()
	_reset_match()

func _load_fighter_names() -> void:
	var session := get_node_or_null("/root/GameSession")
	if session == null:
		return

	if session.has_method("get_p1_display_name"):
		_p1_name = str(session.call("get_p1_display_name"))
	if session.has_method("get_p2_display_name"):
		_p2_name = str(session.call("get_p2_display_name"))

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.color = Color("111827")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 24)
	root_margin.add_theme_constant_override("margin_top", 20)
	root_margin.add_theme_constant_override("margin_right", 24)
	root_margin.add_theme_constant_override("margin_bottom", 20)
	add_child(root_margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	root_margin.add_child(root)

	var title := Label.new()
	title.text = "Battle Arena"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	root.add_child(title)

	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", 20)
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
	_status_label.add_theme_font_size_override("font_size", 20)
	root.add_child(_status_label)

	_timer_label = Label.new()
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 20)
	root.add_child(_timer_label)

	var arena := ColorRect.new()
	arena.color = Color("1f2937")
	arena.custom_minimum_size = Vector2(0, 360)
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(arena)

	var arena_overlay := Control.new()
	arena_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arena.add_child(arena_overlay)

	_arena_p1 = ColorRect.new()
	_arena_p1.color = Color("f59e0b")
	_arena_p1.custom_minimum_size = Vector2(90, 140)
	_arena_p1.position = Vector2(180, 180)
	arena_overlay.add_child(_arena_p1)

	_arena_p2 = ColorRect.new()
	_arena_p2.color = Color("38bdf8")
	_arena_p2.custom_minimum_size = Vector2(90, 140)
	_arena_p2.position = Vector2(900, 180)
	arena_overlay.add_child(_arena_p2)

	_action_hint = Label.new()
	_action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_hint.text = "P1: A/D move, F light, G heavy | P2: J/L move, U light, O heavy"
	root.add_child(_action_hint)

	var action_buttons := HBoxContainer.new()
	action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	action_buttons.add_theme_constant_override("separation", 14)
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

	_center_banner = Label.new()
	_center_banner.visible = false
	_center_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center_banner.add_theme_font_size_override("font_size", 56)
	_center_banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_center_banner.z_index = 10
	add_child(_center_banner)

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

	if event.is_action_pressed("p1_left"):
		_arena_p1.position.x = maxf(_arena_p1.position.x - 24.0, 40.0)
	elif event.is_action_pressed("p1_right"):
		_arena_p1.position.x = minf(_arena_p1.position.x + 24.0, 520.0)
	elif event.is_action_pressed("p2_left"):
		_arena_p2.position.x = maxf(_arena_p2.position.x - 24.0, 620.0)
	elif event.is_action_pressed("p2_right"):
		_arena_p2.position.x = minf(_arena_p2.position.x + 24.0, 1080.0)
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
	if p1_hp <= 0 and p2_hp <= 0:
		_finish_match("Double KO! Press Rematch", "DOUBLE KO", Color("f97316"))
		return

	if p1_hp <= 0:
		_finish_match("%s Wins! Press Rematch" % _p2_name, "%s WINS" % _p2_name.to_upper(), Color("22d3ee"))
	else:
		_finish_match("%s Wins! Press Rematch" % _p1_name, "%s WINS" % _p1_name.to_upper(), Color("f59e0b"))

func _on_rematch_pressed() -> void:
	_reset_match()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset_match() -> void:
	p1_hp = START_HP
	p2_hp = START_HP
	_is_match_over = false
	_fight_enabled = false
	_round_time_left = ROUND_TIME_LIMIT
	_arena_p1.position = Vector2(180, 180)
	_arena_p2.position = Vector2(900, 180)
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
	_show_banner(INTRO_ROUND_TEXT, Color("fde047"))
	await get_tree().create_timer(0.85).timeout
	if current_ticket != _intro_ticket:
		return

	_show_banner("FIGHT!", Color("fb7185"))
	await get_tree().create_timer(0.65).timeout
	if current_ticket != _intro_ticket:
		return

	_center_banner.visible = false
	_fight_enabled = true
	_status_label.text = "Fight!"

func _show_banner(text: String, color: Color) -> void:
	_center_banner.text = text
	_center_banner.modulate = color
	_center_banner.visible = true
	_center_banner.scale = Vector2.ONE

	var tween := create_tween()
	tween.tween_property(_center_banner, "scale", Vector2(1.12, 1.12), 0.16)
	tween.tween_property(_center_banner, "scale", Vector2.ONE, 0.12)

func _resolve_timeout() -> void:
	if p1_hp == p2_hp:
		_finish_match("Time Up - Draw", "DRAW", Color("eab308"))
		return

	if p1_hp > p2_hp:
		_finish_match("%s Wins by Time!" % _p1_name, "%s WINS" % _p1_name.to_upper(), Color("f59e0b"))
		return

	_finish_match("%s Wins by Time!" % _p2_name, "%s WINS" % _p2_name.to_upper(), Color("22d3ee"))

func _finish_match(status_text: String, banner_text: String, banner_color: Color) -> void:
	_is_match_over = true
	_fight_enabled = false
	_status_label.text = status_text
	_show_banner(banner_text, banner_color)

func _flash_target(target: ColorRect) -> void:
	var original := target.color
	target.color = Color("f87171")
	var tween := create_tween()
	tween.tween_property(target, "color", original, 0.18)
