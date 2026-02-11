extends RefCounted
class_name FighterSchemaValidator

const REQUIRED_FIGHTER_FIELDS := [
	"id",
	"name",
	"placeholder_asset_id",
	"base_stats",
	"moves",
]

const REQUIRED_BASE_STATS_FIELDS := [
	"hp",
	"speed",
	"weight",
]

const REQUIRED_MOVE_FIELDS := [
	"id",
	"startup_frames",
	"active_frames",
	"recovery_frames",
	"damage",
	"hitstun_frames",
]

func validate_fighter_data(fighter_data: Dictionary) -> Dictionary:
	for field_name in REQUIRED_FIGHTER_FIELDS:
		if not fighter_data.has(field_name):
			return _error_result("ERR_SCHEMA_FIELD_MISSING", "Missing fighter field: %s" % field_name)

	if not (fighter_data.get("base_stats") is Dictionary):
		return _error_result("ERR_SCHEMA_INVALID_TYPE", "base_stats must be Dictionary")

	var base_stats: Dictionary = fighter_data.get("base_stats", {})
	for field_name in REQUIRED_BASE_STATS_FIELDS:
		if not base_stats.has(field_name):
			return _error_result("ERR_SCHEMA_FIELD_MISSING", "Missing base_stats field: %s" % field_name)

	if not (fighter_data.get("moves") is Array):
		return _error_result("ERR_SCHEMA_INVALID_TYPE", "moves must be Array")

	var moves: Array = fighter_data.get("moves", [])
	if moves.is_empty():
		return _error_result("ERR_SCHEMA_EMPTY_MOVES", "moves cannot be empty")

	for move in moves:
		if not (move is Dictionary):
			return _error_result("ERR_SCHEMA_INVALID_TYPE", "move entry must be Dictionary")
		var move_dict: Dictionary = move
		for field_name in REQUIRED_MOVE_FIELDS:
			if not move_dict.has(field_name):
				return _error_result("ERR_SCHEMA_FIELD_MISSING", "Missing move field: %s" % field_name)

	return {
		"valid": true,
		"error_code": "",
		"error_message": "",
	}

func _error_result(error_code: String, error_message: String) -> Dictionary:
	return {
		"valid": false,
		"error_code": error_code,
		"error_message": error_message,
	}
