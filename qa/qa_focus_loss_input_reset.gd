extends SceneTree

const LocalInputManagerScript := preload("res://scripts/input/local_input_manager.gd")

func _init() -> void:
	var manager = LocalInputManagerScript.new(6)

	manager.set_player_action_pressed("p1", "left", true)
	manager.set_player_action_pressed("p1", "attack", true)
	manager.set_player_action_pressed("p2", "right", true)
	manager.set_player_action_pressed("p2", "guard", true)

	if manager.total_stuck_keys() == 0:
		printerr("Expected non-zero pressed actions before focus loss")
		quit(1)
		return

	manager.simulate_focus_lost()

	var stuck_keys := manager.total_stuck_keys()
	if stuck_keys != 0:
		printerr("Expected stuck keys to be 0 after focus loss reset, got %d" % stuck_keys)
		quit(1)
		return

	print("QA_INPUT_RESET_OK")
	print("STUCK_KEYS:%d" % stuck_keys)
	quit(0)
