extends RefCounted
class_name CharacterSelectState

var allow_mirror_selection := false
var selections := {
	"p1": "",
	"p2": "",
}

func _init(allow_mirror: bool) -> void:
	allow_mirror_selection = allow_mirror

func select_player(player_id: String, fighter_id: String) -> Dictionary:
	if not selections.has(player_id):
		return {
			"ok": false,
			"error_code": "ERR_UNKNOWN_PLAYER",
		}

	var opponent_id := "p2" if player_id == "p1" else "p1"
	var opponent_selection := str(selections.get(opponent_id, ""))
	if not allow_mirror_selection and opponent_selection == fighter_id:
		return {
			"ok": false,
			"error_code": "ERR_MIRROR_NOT_ALLOWED",
		}

	selections[player_id] = fighter_id
	return {
		"ok": true,
		"error_code": "",
	}

func get_selected_fighter(player_id: String) -> String:
	return str(selections.get(player_id, ""))
