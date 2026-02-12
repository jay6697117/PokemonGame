extends Control

const MatchFlowControllerScript := preload("res://scripts/flow/match_flow_controller.gd")

var flow_controller = MatchFlowControllerScript.new()
var _p1_option: OptionButton
var _p2_option: OptionButton
var _status_label: Label

func _ready() -> void:
	_build_ui()
	_populate_fighters()

func select_p1(fighter_id: String) -> Dictionary:
	return flow_controller.select_fighter("p1", fighter_id)

func select_p2(fighter_id: String) -> Dictionary:
	return flow_controller.select_fighter("p2", fighter_id)

func begin_match() -> Dictionary:
	return flow_controller.begin_fight()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.color = Color("202a44")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 520)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Character Select"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	content.add_child(title)

	var hint := Label.new()
	hint.text = "Pick fighters for P1 and P2, then start match"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	content.add_child(hint)

	var selectors := HBoxContainer.new()
	selectors.alignment = BoxContainer.ALIGNMENT_CENTER
	selectors.add_theme_constant_override("separation", 24)
	content.add_child(selectors)

	selectors.add_child(_build_player_picker("P1", true))
	selectors.add_child(_build_player_picker("P2", false))

	_status_label = Label.new()
	_status_label.text = "Ready"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 16)
	content.add_child(_status_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	content.add_child(actions)

	var start_button := Button.new()
	start_button.text = "Start Fight"
	start_button.custom_minimum_size = Vector2(220, 50)
	start_button.pressed.connect(_on_start_pressed)
	actions.add_child(start_button)

	var back_button := Button.new()
	back_button.text = "Back to Main Menu"
	back_button.custom_minimum_size = Vector2(220, 50)
	back_button.pressed.connect(_on_back_pressed)
	actions.add_child(back_button)

	start_button.grab_focus()

func _build_player_picker(player_name: String, is_p1: bool) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(320, 180)
	column.add_theme_constant_override("separation", 10)

	var label := Label.new()
	label.text = "%s Fighter" % player_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	column.add_child(label)

	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.custom_minimum_size = Vector2(300, 42)
	column.add_child(option)

	if is_p1:
		_p1_option = option
	else:
		_p2_option = option

	return column

func _populate_fighters() -> void:
	_p1_option.clear()
	_p2_option.clear()

	var fighter_ids: Array[String] = flow_controller.get_available_fighter_ids()
	if fighter_ids.is_empty():
		fighter_ids = ["volt_rodent", "tide_turtle"]

	for fighter_id in fighter_ids:
		var display_name := fighter_id.replace("_", " ").capitalize()
		_p1_option.add_item(display_name)
		_p1_option.set_item_metadata(_p1_option.item_count - 1, fighter_id)
		_p2_option.add_item(display_name)
		_p2_option.set_item_metadata(_p2_option.item_count - 1, fighter_id)

	if _p2_option.item_count > 1:
		_p2_option.select(1)

func _selected_fighter(option: OptionButton) -> String:
	var index := option.get_selected_id()
	var selected := option.get_item_metadata(index)
	return str(selected)

func _on_start_pressed() -> void:
	var p1_fighter := _selected_fighter(_p1_option)
	var p2_fighter := _selected_fighter(_p2_option)

	var p1_result := select_p1(p1_fighter)
	if not bool(p1_result.get("ok", false)):
		_status_label.text = "P1 selection failed: %s" % str(p1_result.get("error_code", "UNKNOWN"))
		return

	var p2_result := select_p2(p2_fighter)
	if not bool(p2_result.get("ok", false)):
		_status_label.text = "P2 selection failed: %s" % str(p2_result.get("error_code", "UNKNOWN"))
		return

	var begin_result := begin_match()
	if not bool(begin_result.get("ok", false)):
		_status_label.text = "Cannot start match: %s" % str(begin_result.get("error_code", "UNKNOWN"))
		return

	var game_session := get_node_or_null("/root/GameSession")
	if game_session != null and game_session.has_method("start_match"):
		game_session.call("start_match", p1_fighter, p2_fighter)

	_status_label.text = "Loading battle..."
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
