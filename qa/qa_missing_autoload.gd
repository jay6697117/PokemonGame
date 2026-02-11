extends SceneTree

func _init() -> void:
	if not ProjectSettings.has_setting("autoload/GameConfig"):
		printerr("autoload/GameConfig project setting is missing")
		quit(1)
		return

	var autoload_setting: String = str(ProjectSettings.get_setting("autoload/GameConfig", ""))
	if autoload_setting.is_empty():
		printerr("autoload/GameConfig project setting is empty")
		quit(1)
		return

	if load(autoload_setting.replace("*", "")) == null:
		printerr("Failed to load configured GameConfig script")
		quit(1)
		return

	var intentionally_missing := _require_autoload("IntentionallyMissingAutoload")
	if intentionally_missing == null:
		print("QA_MISSING_AUTOLOAD_HANDLED")
		quit(0)
		return

	printerr("IntentionallyMissingAutoload unexpectedly exists")
	quit(1)

func _require_autoload(autoload_name: String) -> Node:
	return get_root().get_node_or_null(autoload_name)
