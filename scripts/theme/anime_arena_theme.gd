class_name AnimeArenaTheme
extends RefCounted

const HUD_THEME_PROFILE := "ANIME_ARENA"

# Backgrounds
const COLOR_BACKGROUND_MAIN := Color("111827")
const COLOR_ARENA_FLOOR := Color("1f2937")

# Atmosphere
const COLOR_SKY_TOP := Color("0f172a") # Slate-900
const COLOR_SKY_BOTTOM := Color("1e293b") # Slate-800
const COLOR_GRID_LINES := Color("334155") # Slate-700
const COLOR_PARTICLES := Color("94a3b8", 0.3) # Slate-400 with alpha

# Players
const COLOR_P1_BASE := Color("f59e0b") # Amber-500
const COLOR_P2_BASE := Color("38bdf8") # Sky-400

# UI Status / Feedback
const COLOR_HIT_FLASH := Color("f87171") # Red-400
const COLOR_WIN_P1 := Color("f59e0b")
const COLOR_WIN_P2 := Color("22d3ee") # Cyan-400
const COLOR_DRAW := Color("eab308") # Yellow-500
const COLOR_DOUBLE_KO := Color("f97316") # Orange-500

# Banners / Intro
const COLOR_BANNER_ROUND := Color("fde047") # Yellow-300
const COLOR_BANNER_FIGHT := Color("fb7185") # Rose-400
const COLOR_BANNER_KO := Color("ef4444") # Red-500
const COLOR_BANNER_TIME_UP := Color("f59e0b") # Amber-500

# Text / Layout
const FONT_SIZE_TITLE := 32
const FONT_SIZE_HUD_LABEL := 20
const FONT_SIZE_BANNER_LARGE := 80
const BANNER_ANIM_SCALE_START := Vector2(3.0, 3.0)
const BANNER_ANIM_SCALE_END := Vector2.ONE
const BANNER_ANIM_DURATION_IN := 0.25
const BANNER_ANIM_DURATION_OUT := 0.15

const MARGIN_OUTER_X := 24
const MARGIN_OUTER_Y := 20
const SPACING_MAIN_V := 14
const SPACING_BARS_H := 20
