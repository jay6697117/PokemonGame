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
	
	# Verify Visual Layer Binding
	var visual_script = load("res://scripts/visuals/fighter_visual.gd")
	if visual_script == null:
		printerr("ERROR: scripts/visuals/fighter_visual.gd not found")
		quit(1)
		return
		
	var visual_scene = load("res://scripts/visuals/fighter_visual.tscn")
	if visual_scene == null:
		printerr("ERROR: scripts/visuals/fighter_visual.tscn not found")
		quit(1)
		return
		
	# Check if battle_screen.gd references FighterVisual
	var battle_script_path = "res://scripts/flow/battle_screen.gd"
	var file = FileAccess.open(battle_script_path, FileAccess.READ)
	var content = file.get_as_text()
	if not "const FighterVisual" in content:
		printerr("ERROR: battle_screen.gd does not reference FighterVisual")
		quit(1)
		return
		
	print("FIGHTER_VISUALS_BOUND:true")
	
	# Check for Stage Atmosphere
	if not FileAccess.file_exists("res://scripts/visuals/arena_atmosphere.gd"):
		printerr("ERROR: scripts/visuals/arena_atmosphere.gd not found")
		quit(1)
		return
		
	if not "const ArenaAtmosphereScript" in content:
		printerr("ERROR: battle_screen.gd does not reference ArenaAtmosphereScript")
		quit(1)
		return
		
	print("STAGE_ATMOSPHERE_ACTIVE:true")
	
	# Check for Anime Arena Banner Style
	if not const_map.has("BANNER_ANIM_SCALE_START"):
		printerr("ERROR: AnimeArenaTheme missing BANNER_ANIM_SCALE_START constant")
		quit(1)
		return

	if not "_hide_banner" in content:
		printerr("ERROR: battle_screen.gd missing _hide_banner method")
		quit(1)
		return

	print("ROUND_TRANSITION_STYLE_OK")
	print("QA_PHASE1_VISUAL_CONTRACT_OK")
	
	quit(0)
