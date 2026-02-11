extends Node

const MatchFlowControllerScript := preload("res://scripts/flow/match_flow_controller.gd")

var flow_controller = MatchFlowControllerScript.new()

func select_p1(fighter_id: String) -> Dictionary:
	return flow_controller.select_fighter("p1", fighter_id)

func select_p2(fighter_id: String) -> Dictionary:
	return flow_controller.select_fighter("p2", fighter_id)

func begin_match() -> Dictionary:
	return flow_controller.begin_fight()
