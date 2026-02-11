extends RefCounted
class_name LocalInputManager

const PlayerInputChannelScript := preload("res://scripts/input/player_input_channel.gd")

const PLAYER_IDS := ["p1", "p2"]

var channels: Dictionary = {}

func _init(buffer_window_frames: int = 6) -> void:
	for player_id in PLAYER_IDS:
		channels[player_id] = PlayerInputChannelScript.new(player_id, buffer_window_frames)

func record_player_action(player_id: String, action_name: String, current_frame: int) -> void:
	var channel = get_channel(player_id)
	if channel == null:
		return
	channel.record_action(action_name, current_frame)

func consume_player_action(player_id: String, valid_actions: Array[String], current_frame: int) -> Dictionary:
	var channel = get_channel(player_id)
	if channel == null:
		return {}
	return channel.consume_buffered_action(valid_actions, current_frame)

func set_player_action_pressed(player_id: String, action_name: String, is_pressed: bool) -> void:
	var channel = get_channel(player_id)
	if channel == null:
		return
	channel.set_pressed(action_name, is_pressed)

func get_channel(player_id: String) -> RefCounted:
	return channels.get(player_id, null)

func simulate_focus_lost() -> void:
	for channel in channels.values():
		channel.clear_pressed()

func reset_for_rematch() -> void:
	for channel in channels.values():
		channel.clear_transient_state()

func total_buffered_actions() -> int:
	var total := 0
	for channel in channels.values():
		total += channel.buffered_action_count()
	return total

func total_stuck_keys() -> int:
	var total := 0
	for channel in channels.values():
		total += channel.stuck_keys_count()
	return total
