extends Node

const AnimeArenaTheme := preload("res://scripts/theme/anime_arena_theme.gd")

var _sky: ColorRect
var _floor: ColorRect
var _particles: CPUParticles2D

func setup(background_layer: Node, fighter_layer: Node, vfx_layer: Node) -> void:
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
	# Center vertically, full width
	_floor.custom_minimum_size = Vector2(0, 360)
	_floor.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_floor.anchor_top = 0.5
	_floor.anchor_bottom = 0.5
	_floor.anchor_left = 0.0
	_floor.anchor_right = 1.0
	_floor.offset_top = -180
	_floor.offset_bottom = 180
	# Add as first child to be behind fighters
	fighter_layer.add_child(_floor)
	fighter_layer.move_child(_floor, 0)
	
	# 3. Particles (Vfx Layer - Foreground)
	_particles = CPUParticles2D.new()
	_particles.name = "AtmosphereParticles"
	_particles.position = Vector2(640, 360)
	_particles.amount = 32
	_particles.lifetime = 4.0
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(640, 360)
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

func is_active() -> bool:
	return _sky != null and _floor != null and _particles != null
