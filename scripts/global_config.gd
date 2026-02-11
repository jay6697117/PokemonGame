extends Node

const TARGET_FPS := 60
const DEFAULT_HP := 1000
const ROUND_DURATION_SECONDS := 60
const BEST_OF_ROUNDS := 3

const INPUT_BINDINGS := {
	"p1_up": Key.KEY_W,
	"p1_down": Key.KEY_S,
	"p1_left": Key.KEY_A,
	"p1_right": Key.KEY_D,
	"p1_light": Key.KEY_F,
	"p1_heavy": Key.KEY_G,
	"p1_guard": Key.KEY_H,
	"p2_up": Key.KEY_I,
	"p2_down": Key.KEY_K,
	"p2_left": Key.KEY_J,
	"p2_right": Key.KEY_L,
	"p2_light": Key.KEY_U,
	"p2_heavy": Key.KEY_O,
	"p2_guard": Key.KEY_P,
}

func _ready() -> void:
	_apply_engine_baseline()
	_ensure_input_actions()

func _apply_engine_baseline() -> void:
	Engine.physics_ticks_per_second = TARGET_FPS
	Engine.max_fps = TARGET_FPS

func _ensure_input_actions() -> void:
	for action_name: String in INPUT_BINDINGS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		_ensure_key_binding(action_name, INPUT_BINDINGS[action_name])

func _ensure_key_binding(action_name: String, keycode: Key) -> void:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.physical_keycode == keycode:
				return

	var new_event := InputEventKey.new()
	new_event.physical_keycode = keycode
	new_event.keycode = keycode
	InputMap.action_add_event(action_name, new_event)

func get_match_defaults() -> Dictionary:
	return {
		"target_fps": TARGET_FPS,
		"default_hp": DEFAULT_HP,
		"round_duration_seconds": ROUND_DURATION_SECONDS,
		"best_of_rounds": BEST_OF_ROUNDS,
	}
