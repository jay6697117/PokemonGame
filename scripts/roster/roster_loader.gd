extends RefCounted
class_name RosterLoader

const FighterSchemaValidatorScript := preload("res://scripts/roster/fighter_schema_validator.gd")

var _validator = FighterSchemaValidatorScript.new()

func load_roster(roster_path: String = "res://data/roster.json") -> Dictionary:
	var roster_data_result := _load_json_file(roster_path)
	if not bool(roster_data_result.get("ok", false)):
		return roster_data_result

	var roster_data: Dictionary = roster_data_result.get("data", {})
	if not (roster_data.get("fighters") is Array):
		return {
			"ok": false,
			"error_code": "ERR_ROSTER_FORMAT",
			"error_message": "fighters must be an array",
		}

	var fighters: Array = roster_data.get("fighters", [])
	var loaded_fighters: Array[Dictionary] = []

	for fighter_entry in fighters:
		if not (fighter_entry is Dictionary):
			return {
				"ok": false,
				"error_code": "ERR_ROSTER_FORMAT",
				"error_message": "fighter entry must be dictionary",
			}

		var fighter_record: Dictionary = fighter_entry
		if not fighter_record.has("file"):
			return {
				"ok": false,
				"error_code": "ERR_SCHEMA_FIELD_MISSING",
				"error_message": "fighter entry missing file",
			}

		var fighter_file_path := str(fighter_record.get("file", ""))
		var fighter_data_result := _load_json_file(fighter_file_path)
		if not bool(fighter_data_result.get("ok", false)):
			return fighter_data_result

		var fighter_data: Dictionary = fighter_data_result.get("data", {})
		var validation_result: Dictionary = _validator.validate_fighter_data(fighter_data)
		if not bool(validation_result.get("valid", false)):
			return {
				"ok": false,
				"error_code": validation_result.get("error_code", "ERR_SCHEMA_UNKNOWN"),
				"error_message": validation_result.get("error_message", "validation failed"),
			}

		loaded_fighters.append(fighter_data)

	return {
		"ok": true,
		"allow_mirror_selection": bool(roster_data.get("allow_mirror_selection", false)),
		"fighters": loaded_fighters,
	}

func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {
			"ok": false,
			"error_code": "ERR_FILE_NOT_FOUND",
			"error_message": "Missing file: %s" % path,
		}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"error_code": "ERR_FILE_OPEN_FAILED",
			"error_message": "Failed to open file: %s" % path,
		}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_status := json.parse(json_text)
	if parse_status != OK:
		return {
			"ok": false,
			"error_code": "ERR_JSON_PARSE",
			"error_message": "JSON parse failed: %s" % path,
		}

	if not (json.data is Dictionary):
		return {
			"ok": false,
			"error_code": "ERR_JSON_FORMAT",
			"error_message": "JSON root must be dictionary: %s" % path,
		}

	return {
		"ok": true,
		"data": json.data,
	}
