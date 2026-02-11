extends SceneTree

const LocalInputManagerScript := preload("res://scripts/input/local_input_manager.gd")

func _init() -> void:
	var manager = LocalInputManagerScript.new(6)

	manager.record_player_action("p1", "attack", 10)

	for frame in range(11, 14):
		var ignored_result: Dictionary = manager.consume_player_action("p1", [], frame)
		if not ignored_result.is_empty():
			printerr("Buffered action should not trigger during recovery frame %d" % frame)
			quit(1)
			return

	var result: Dictionary = manager.consume_player_action("p1", ["attack"], 14)
	if result.is_empty():
		printerr("Buffered attack was not triggered")
		quit(1)
		return

	var action_name := str(result.get("action_name", ""))
	var trigger_frame := int(result.get("trigger_frame", -1))
	if action_name != "attack":
		printerr("Expected attack action, got %s" % action_name)
		quit(1)
		return

	if trigger_frame != 14:
		printerr("Expected trigger frame 14, got %d" % trigger_frame)
		quit(1)
		return

	var repeated_result: Dictionary = manager.consume_player_action("p1", ["attack"], 15)
	if not repeated_result.is_empty():
		printerr("Buffered attack should trigger exactly once")
		quit(1)
		return

	print("QA_INPUT_BUFFER_OK")
	print("BUFFERED_ATTACK_TRIGGERED_AT_FRAME:%d" % trigger_frame)
	quit(0)
