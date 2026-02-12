extends Node

const DEFAULT_P1 := "volt_rodent"
const DEFAULT_P2 := "tide_turtle"

var p1_fighter_id := DEFAULT_P1
var p2_fighter_id := DEFAULT_P2

func start_match(p1_id: String, p2_id: String) -> void:
	p1_fighter_id = p1_id
	p2_fighter_id = p2_id

func reset() -> void:
	p1_fighter_id = DEFAULT_P1
	p2_fighter_id = DEFAULT_P2

func get_p1_display_name() -> String:
	return _display_name(p1_fighter_id)

func get_p2_display_name() -> String:
	return _display_name(p2_fighter_id)

func _display_name(fighter_id: String) -> String:
	var normalized := fighter_id.strip_edges().replace("_", " ")
	if normalized.is_empty():
		return "Unknown"
	return normalized.capitalize()
