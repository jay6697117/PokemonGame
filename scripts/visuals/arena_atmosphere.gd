extends Node

const AnimeArenaTheme := preload("res://scripts/theme/anime_arena_theme.gd")

var _sky: ColorRect
var _floor: ColorRect
var _particles: CPUParticles2D
var _layout_metrics: Dictionary = {}

func setup(background_layer: Node, fighter_layer: Node, vfx_layer: Node, layout_metrics: Dictionary = {}) -> void:
	_layout_metrics = layout_metrics.duplicate(true)
	if _layout_metrics.is_empty():
		_layout_metrics = _default_layout_metrics()

	# 1. Sky (Background Layer)
	_sky = ColorRect.new()
	_sky.name = "SkyBackground"
	_sky.color = AnimeArenaTheme.COLOR_SKY_TOP
	_sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_layer.add_child(_sky)
	
	# 2. Floor (Fighter Layer - behind fighters)
	_floor = ColorRect.new()
	_floor.name = "ArenaFloor"
	_floor.color = AnimeArenaTheme.COLOR_ARENA_FLOOR
	_floor.custom_minimum_size = Vector2(0, float(_layout_metrics.get("spacer_height", 360.0)))
	_floor.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_floor.anchor_top = 0.5
	_floor.anchor_bottom = 0.5
	_floor.anchor_left = 0.0
	_floor.anchor_right = 1.0
	_floor.offset_top = -float(_layout_metrics.get("half_height", 180.0))
	_floor.offset_bottom = float(_layout_metrics.get("half_height", 180.0))
	# Add as first child to be behind fighters
	fighter_layer.add_child(_floor)
	fighter_layer.move_child(_floor, 0)
	
	# 3. Particles (Vfx Layer - Foreground)
	_particles = CPUParticles2D.new()
	_particles.name = "AtmosphereParticles"
	_particles.position = _layout_metrics.get("banner_pivot", Vector2(640, 360))
	_particles.amount = 32
	_particles.lifetime = 4.0
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = _layout_metrics.get("banner_pivot", Vector2(640, 360))
	_particles.direction = Vector2(0, -1)
	_particles.spread = 0
	_particles.gravity = Vector2(0, 0)
	_particles.initial_velocity_min = 20
	_particles.initial_velocity_max = 40
	_particles.scale_amount_min = 2.0
	_particles.scale_amount_max = 4.0
	_particles.color = AnimeArenaTheme.COLOR_PARTICLES
	vfx_layer.add_child(_particles)
	
	# Simple pulse animation for sky
	var tween = create_tween().set_loops()
	tween.tween_property(_sky, "color", AnimeArenaTheme.COLOR_SKY_BOTTOM, 4.0)
	tween.tween_property(_sky, "color", AnimeArenaTheme.COLOR_SKY_TOP, 4.0)

func apply_layout_metrics(layout_metrics: Dictionary) -> void:
	if layout_metrics.is_empty():
		return

	_layout_metrics = layout_metrics.duplicate(true)

	if _floor != null:
		_floor.custom_minimum_size = Vector2(0, float(_layout_metrics.get("spacer_height", 360.0)))
		_floor.offset_top = -float(_layout_metrics.get("half_height", 180.0))
		_floor.offset_bottom = float(_layout_metrics.get("half_height", 180.0))

	if _particles != null:
		var center: Vector2 = _layout_metrics.get("banner_pivot", Vector2(640, 360))
		_particles.position = center
		_particles.emission_rect_extents = center

func _default_layout_metrics() -> Dictionary:
	return {
		"spacer_height": 360.0,
		"half_height": 180.0,
		"banner_pivot": Vector2(640, 360),
	}

func is_active() -> bool:
	return _sky != null and _floor != null and _particles != null
