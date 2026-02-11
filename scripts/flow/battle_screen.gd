extends Node

func apply_test_damage(flow_controller: RefCounted, target_player: String, damage: int) -> void:
	if flow_controller == null:
		return
	if flow_controller.has_method("apply_damage"):
		flow_controller.call("apply_damage", target_player, damage)
