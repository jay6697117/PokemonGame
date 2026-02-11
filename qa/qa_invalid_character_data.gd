extends SceneTree

const FighterSchemaValidatorScript := preload("res://scripts/roster/fighter_schema_validator.gd")

func _init() -> void:
	var validator = FighterSchemaValidatorScript.new()

	var invalid_fighter_data := {
		"id": "broken_fighter",
		"name": "Broken Fighter",
		"placeholder_asset_id": "broken_asset",
		"base_stats": {
			"hp": 1000,
			"speed": 1.0,
			"weight": 1.0,
		},
		# Missing `moves`
	}

	var validation_result: Dictionary = validator.validate_fighter_data(invalid_fighter_data)
	if bool(validation_result.get("valid", true)):
		printerr("Invalid fighter data unexpectedly passed validation")
		quit(1)
		return

	var error_code := str(validation_result.get("error_code", ""))
	if error_code != "ERR_SCHEMA_FIELD_MISSING":
		printerr("Unexpected error code: %s" % error_code)
		quit(1)
		return

	print("QA_INVALID_CHARACTER_DATA_HANDLED")
	print(error_code)
	quit(0)
