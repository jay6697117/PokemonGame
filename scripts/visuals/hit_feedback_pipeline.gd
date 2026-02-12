extends Node
class_name HitFeedbackPipeline

const AnimeArenaTheme := preload("res://scripts/theme/anime_arena_theme.gd")

const SPARK_SIZE := Vector2(28.0, 28.0)
const SPARK_DURATION := 0.10
const SPARK_VERTICAL_OFFSET := -74.0
const FLASH_DURATION := 0.18
const SHAKE_OFFSET := 5.0
const SHAKE_STEP_DURATION := 0.022
const HIT_STOP_DURATION := 0.035
const HIT_STOP_RECOVER_DURATION := 0.045

var _fighter_layer: Control
var _vfx_layer: Control
var _overlay_layer: Control

var _base_fighter_layer_position := Vector2.ZERO
var _base_vfx_layer_position := Vector2.ZERO
var _base_fighter_layer_scale := Vector2.ONE
var _base_vfx_layer_scale := Vector2.ONE
var _shake_tween: Tween
var _hit_stop_overlay_tween: Tween
var _hit_stop_overlay: ColorRect

var _total_hits := 0
var _spark_count := 0
var _flash_count := 0
var _shake_count := 0
var _hit_stop_count := 0

func setup(fighter_layer: Control, vfx_layer: Control, overlay_layer: Control) -> void:
	_fighter_layer = fighter_layer
	_vfx_layer = vfx_layer
	_overlay_layer = overlay_layer
	_base_fighter_layer_position = _fighter_layer.position
	_base_vfx_layer_position = _vfx_layer.position
	_base_fighter_layer_scale = _fighter_layer.scale
	_base_vfx_layer_scale = _vfx_layer.scale
	_ensure_hit_stop_overlay()
	reset_temporary_state()

func play_hit_feedback(victim: Node2D) -> void:
	if victim == null:
		return
	_total_hits += 1
	_spawn_hit_spark(victim)
	if victim.has_method("flash"):
		victim.call("flash", AnimeArenaTheme.COLOR_HIT_FLASH, FLASH_DURATION)
		_flash_count += 1
	_play_camera_shake_cue()
	_play_micro_hit_stop(victim)

func get_feedback_metrics() -> Dictionary:
	return {
		"total_hits": _total_hits,
		"spark_count": _spark_count,
		"flash_count": _flash_count,
		"shake_count": _shake_count,
		"hit_stop_count": _hit_stop_count,
	}

func reset_temporary_state() -> void:
	if _shake_tween != null:
		_shake_tween.kill()
		_shake_tween = null
	if _hit_stop_overlay_tween != null:
		_hit_stop_overlay_tween.kill()
		_hit_stop_overlay_tween = null

	if _fighter_layer != null:
		_fighter_layer.position = _base_fighter_layer_position
		_fighter_layer.scale = _base_fighter_layer_scale

	if _vfx_layer != null:
		_vfx_layer.position = _base_vfx_layer_position
		_vfx_layer.scale = _base_vfx_layer_scale
		for child in _vfx_layer.get_children():
			if child is CanvasItem and str(child.name).begins_with("HitSpark_"):
				child.queue_free()

	if _hit_stop_overlay != null:
		_hit_stop_overlay.modulate.a = 0.0

	_total_hits = 0
	_spark_count = 0
	_flash_count = 0
	_shake_count = 0
	_hit_stop_count = 0

func _spawn_hit_spark(victim: Node2D) -> void:
	if _vfx_layer == null:
		return

	var spark := ColorRect.new()
	spark.name = "HitSpark_%d" % _total_hits
	spark.color = AnimeArenaTheme.COLOR_BANNER_FIGHT
	spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spark.custom_minimum_size = SPARK_SIZE
	spark.size = SPARK_SIZE
	spark.pivot_offset = SPARK_SIZE * 0.5
	var local_position := _to_local_position(_vfx_layer, victim.global_position + Vector2(0.0, SPARK_VERTICAL_OFFSET))
	spark.position = local_position - (SPARK_SIZE * 0.5)
	_vfx_layer.add_child(spark)
	_spark_count += 1

	var tween := create_tween()
	tween.tween_property(spark, "scale", Vector2(1.6, 1.6), SPARK_DURATION * 0.5)
	tween.parallel().tween_property(spark, "modulate:a", 0.0, SPARK_DURATION)
	tween.tween_callback(Callable(spark, "queue_free"))

func _play_camera_shake_cue() -> void:
	if _fighter_layer == null or _vfx_layer == null:
		return

	_shake_count += 1
	if _shake_tween != null:
		_shake_tween.kill()

	_fighter_layer.position = _base_fighter_layer_position
	_vfx_layer.position = _base_vfx_layer_position

	_shake_tween = create_tween()
	_shake_tween.tween_property(_fighter_layer, "position", _base_fighter_layer_position + Vector2(-SHAKE_OFFSET, 0.0), SHAKE_STEP_DURATION)
	_shake_tween.parallel().tween_property(_vfx_layer, "position", _base_vfx_layer_position + Vector2(-SHAKE_OFFSET, 0.0), SHAKE_STEP_DURATION)
	_shake_tween.tween_property(_fighter_layer, "position", _base_fighter_layer_position + Vector2(SHAKE_OFFSET, 0.0), SHAKE_STEP_DURATION)
	_shake_tween.parallel().tween_property(_vfx_layer, "position", _base_vfx_layer_position + Vector2(SHAKE_OFFSET, 0.0), SHAKE_STEP_DURATION)
	_shake_tween.tween_property(_fighter_layer, "position", _base_fighter_layer_position, SHAKE_STEP_DURATION)
	_shake_tween.parallel().tween_property(_vfx_layer, "position", _base_vfx_layer_position, SHAKE_STEP_DURATION)

func _play_micro_hit_stop(victim: Node2D) -> void:
	_hit_stop_count += 1
	if victim.has_method("hit_stop"):
		victim.call("hit_stop", HIT_STOP_DURATION, HIT_STOP_RECOVER_DURATION)

	if _hit_stop_overlay == null:
		return

	if _hit_stop_overlay_tween != null:
		_hit_stop_overlay_tween.kill()

	_hit_stop_overlay.modulate = Color(1.0, 1.0, 1.0, 0.16)
	_hit_stop_overlay_tween = create_tween()
	_hit_stop_overlay_tween.tween_interval(HIT_STOP_DURATION)
	_hit_stop_overlay_tween.tween_property(_hit_stop_overlay, "modulate:a", 0.0, HIT_STOP_RECOVER_DURATION)

func _ensure_hit_stop_overlay() -> void:
	if _overlay_layer == null or _hit_stop_overlay != null:
		return

	_hit_stop_overlay = ColorRect.new()
	_hit_stop_overlay.name = "HitStopOverlayCue"
	_hit_stop_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hit_stop_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hit_stop_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hit_stop_overlay.z_index = 1
	_overlay_layer.add_child(_hit_stop_overlay)

func _to_local_position(layer: CanvasItem, global_position: Vector2) -> Vector2:
	return layer.get_global_transform_with_canvas().affine_inverse() * global_position
