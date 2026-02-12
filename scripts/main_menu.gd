extends Control

@export_file("*.tscn") var character_select_scene: String = "res://scenes/character_select.tscn"

func _ready() -> void:
	_build_ui()

func goto_character_select() -> int:
	return get_tree().change_scene_to_file(character_select_scene)

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color("1a2238")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 420)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 16)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Pokemon KOF Private Prototype"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "2D Local Versus Demo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	content.add_child(subtitle)

	var controls := Label.new()
	controls.text = "Press Enter or click Start Demo\nP1: WASD + F/G/H | P2: IJKL + U/O/P"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 16)
	content.add_child(controls)

	var start_button := Button.new()
	start_button.text = "Start Demo"
	start_button.custom_minimum_size = Vector2(260, 56)
	start_button.pressed.connect(_on_start_pressed)
	content.add_child(start_button)

	var quit_button := Button.new()
	quit_button.text = "Quit"
	quit_button.custom_minimum_size = Vector2(260, 46)
	quit_button.pressed.connect(_on_quit_pressed)
	content.add_child(quit_button)

	start_button.grab_focus()

func _on_start_pressed() -> void:
	goto_character_select()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()
