extends Node

@export_file("*.tscn") var character_select_scene: String = "res://scenes/character_select.tscn"

func goto_character_select() -> int:
	return get_tree().change_scene_to_file(character_select_scene)
