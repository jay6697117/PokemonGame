extends RefCounted
class_name PlayerInputChannel

const DIRECTION_ACTIONS := {
	"up": true,
	"down": true,
	"left": true,
	"right": true,
}

var player_id := ""
var buffer_window_frames := 6
var _action_buffer: Array[Dictionary] = []
var _direction_history: Array[Dictionary] = []
var _pressed_actions: Dictionary = {}

func _init(id: String, window_frames: int = 6) -> void:
	player_id = id
	buffer_window_frames = max(window_frames, 1)

func record_action(action_name: String, current_frame: int) -> void:
	_action_buffer.append({
		"action_name": action_name,
		"buffered_at": current_frame,
	})

	if DIRECTION_ACTIONS.has(action_name):
		_direction_history.append({
			"direction": action_name,
			"frame": current_frame,
		})

	_prune_expired_entries(current_frame)

func consume_buffered_action(valid_actions: Array[String], current_frame: int) -> Dictionary:
	_prune_expired_entries(current_frame)

	for index in _action_buffer.size():
		var entry: Dictionary = _action_buffer[index]
		var action_name := str(entry.get("action_name", ""))
		if valid_actions.has(action_name):
			_action_buffer.remove_at(index)
			entry["trigger_frame"] = current_frame
			return entry

	return {}

func matches_direction_sequence(expected: Array[String], current_frame: int) -> bool:
	if expected.is_empty():
		return false

	_prune_expired_entries(current_frame)

	var history: Array[String] = []
	for item in _direction_history:
		history.append(str(item.get("direction", "")))

	if history.size() < expected.size():
		return false

	var cursor := 0
	for direction in history:
		if direction == expected[cursor]:
			cursor += 1
			if cursor == expected.size():
				return true

	return false

func set_pressed(action_name: String, is_pressed: bool) -> void:
	if is_pressed:
		_pressed_actions[action_name] = true
		return

	_pressed_actions.erase(action_name)

func clear_pressed() -> void:
	_pressed_actions.clear()

func clear_transient_state() -> void:
	_action_buffer.clear()
	_direction_history.clear()
	_pressed_actions.clear()

func buffered_action_count() -> int:
	return _action_buffer.size()

func stuck_keys_count() -> int:
	return _pressed_actions.size()

func _prune_expired_entries(current_frame: int) -> void:
	var min_frame := current_frame - buffer_window_frames

	var pruned_action_buffer: Array[Dictionary] = []
	for entry in _action_buffer:
		if int(entry.get("buffered_at", -9999)) >= min_frame:
			pruned_action_buffer.append(entry)
	_action_buffer = pruned_action_buffer

	var pruned_direction_history: Array[Dictionary] = []
	for entry in _direction_history:
		if int(entry.get("frame", -9999)) >= min_frame:
			pruned_direction_history.append(entry)
	_direction_history = pruned_direction_history
