extends SceneTree

const REQUIRED_INPUT_ACTIONS := [
	"p1_up",
	"p1_down",
	"p1_left",
	"p1_right",
	"p1_light",
	"p1_heavy",
	"p1_guard",
	"p2_up",
	"p2_down",
	"p2_left",
	"p2_right",
	"p2_light",
	"p2_heavy",
	"p2_guard",
]

func _init() -> void:
	var failures: PackedStringArray = []

	_validate_project_settings(failures)
	_validate_autoload_config(failures)
	_validate_input_map(failures)

	if failures.is_empty():
		print("QA_PROJECT_BOOTSTRAP_OK")
		quit(0)
		return

	for failure: String in failures:
		printerr(failure)
	quit(1)

func _validate_project_settings(failures: PackedStringArray) -> void:
	if not ProjectSettings.has_setting("application/config/name"):
		failures.append("Missing application/config/name setting")

	if not ProjectSettings.has_setting("application/run/main_scene"):
		failures.append("Missing application/run/main_scene setting")

	if int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 0)) != 60:
		failures.append("physics/common/physics_ticks_per_second must be 60")

func _validate_autoload_config(failures: PackedStringArray) -> void:
	if not ProjectSettings.has_setting("autoload/GameConfig"):
		failures.append("autoload/GameConfig project setting is missing")
		return

	var autoload_setting: String = str(ProjectSettings.get_setting("autoload/GameConfig", ""))
	if autoload_setting.is_empty():
		failures.append("autoload/GameConfig project setting is empty")
		return

	var script_path := autoload_setting.replace("*", "")
	var config_node := get_root().get_node_or_null("GameConfig")
	if config_node == null:
		var loaded_script: Variant = load(script_path)
		if not (loaded_script is Script):
			failures.append("Failed to load GameConfig script: %s" % script_path)
			return

		var config_script: Script = loaded_script
		var config_instance: Variant = config_script.new()
		if not (config_instance is Node):
			failures.append("GameConfig script does not extend Node")
			return

		config_node = config_instance
		config_node.name = "GameConfig"
		get_root().add_child(config_node)

	if config_node.has_method("_apply_engine_baseline"):
		config_node.call("_apply_engine_baseline")
	if config_node.has_method("_ensure_input_actions"):
		config_node.call("_ensure_input_actions")

	if not config_node.has_method("get_match_defaults"):
		failures.append("GameConfig.get_match_defaults is missing")
		return

	var defaults: Variant = config_node.call("get_match_defaults")
	if not (defaults is Dictionary):
		failures.append("GameConfig.get_match_defaults must return Dictionary")
		return

	var defaults_dict: Dictionary = defaults
	if int(defaults_dict.get("target_fps", -1)) != 60:
		failures.append("target_fps must be 60")
	if int(defaults_dict.get("default_hp", -1)) != 1000:
		failures.append("default_hp must be 1000")
	if int(defaults_dict.get("round_duration_seconds", -1)) != 60:
		failures.append("round_duration_seconds must be 60")
	if int(defaults_dict.get("best_of_rounds", -1)) != 3:
		failures.append("best_of_rounds must be 3")

func _validate_input_map(failures: PackedStringArray) -> void:
	for action_name: String in REQUIRED_INPUT_ACTIONS:
		if not InputMap.has_action(action_name):
			failures.append("Missing InputMap action: %s" % action_name)
			continue

		if InputMap.action_get_events(action_name).is_empty():
			failures.append("InputMap action has no binding: %s" % action_name)
