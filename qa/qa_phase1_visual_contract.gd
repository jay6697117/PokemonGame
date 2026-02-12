extends SceneTree

func _init() -> void:
	var theme_script = load("res://scripts/theme/anime_arena_theme.gd")
	if theme_script == null:
		printerr("ERROR: scripts/theme/anime_arena_theme.gd not found")
		quit(1)
		return

	var const_map = theme_script.get_script_constant_map()
	if not const_map.has("HUD_THEME_PROFILE"):
		printerr("ERROR: HUD_THEME_PROFILE constant missing in AnimeArenaTheme")
		quit(1)
		return
	
	var profile = const_map["HUD_THEME_PROFILE"]
	if profile != "ANIME_ARENA":
		printerr("ERROR: HUD_THEME_PROFILE is '%s', expected 'ANIME_ARENA'" % str(profile))
		quit(1)
		return
		
	print("HUD_THEME_PROFILE:ANIME_ARENA")

	# Check Battle Scene Structure
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	var required_layers = ["BackgroundLayer", "FighterLayer", "VfxLayer", "HudLayer", "OverlayLayer"]
	var missing = []
	for layer in required_layers:
		if not battle_scene.has_node(layer):
			missing.append(layer)
			
	if missing.size() > 0:
		printerr("ERROR: Missing required layers in battle.tscn: ", missing)
		battle_scene.free()
		quit(1)
		return

	print("REQUIRED_NODES_PRESENT:true")
	battle_scene.free()
	
	quit(0)
