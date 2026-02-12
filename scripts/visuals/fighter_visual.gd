extends Node2D
class_name FighterVisual

var body: ColorRect
var face_indicator: ColorRect
var _hit_stop_tween: Tween
var _flash_tween: Tween
var _rest_scale := Vector2.ONE
var _rest_body_color := Color.WHITE

var fighter_id: String = ""
var is_mirror: bool = false
var is_p2_slot: bool = false

func _ready() -> void:
	if not has_node("Body"):
		_create_placeholder_nodes()
	else:
		body = $Body
		face_indicator = $Body/FaceIndicator

	_rest_scale = scale
	_update_visuals()
	if body != null:
		_rest_body_color = body.color

func capture_rest_scale() -> void:
	_rest_scale = scale

func reset_temporary_feedback_state() -> void:
	if _hit_stop_tween != null:
		_hit_stop_tween.kill()
		_hit_stop_tween = null
	if _flash_tween != null:
		_flash_tween.kill()
		_flash_tween = null
	scale = _rest_scale
	if body != null:
		body.color = _rest_body_color

func _create_placeholder_nodes() -> void:
	body = ColorRect.new()
	body.name = "Body"
	body.custom_minimum_size = Vector2(90, 140)
	body.position = Vector2(-45, -140) # Pivot at bottom center
	add_child(body)
	
	face_indicator = ColorRect.new()
	face_indicator.name = "FaceIndicator"
	face_indicator.custom_minimum_size = Vector2(20, 20)
	face_indicator.color = Color.WHITE
	face_indicator.position = Vector2(25, 10) # Right side eye/indicator relative to body
	body.add_child(face_indicator)

func setup(id: String, mirror: bool, p2_slot: bool) -> void:
	fighter_id = id
	is_mirror = mirror
	is_p2_slot = p2_slot
	if is_inside_tree():
		_update_visuals()

func _update_visuals() -> void:
	if not body:
		return
		
	# Base color based on ID (fallback if no specific texture)
	# This simulates loading assets
	if fighter_id == "volt_rodent":
		body.color = Color(1.0, 0.8, 0.2) # Electric Yellow
	elif fighter_id == "tide_turtle":
		body.color = Color(0.2, 0.6, 1.0) # Water Blue
	else:
		body.color = Color(0.5, 0.5, 0.5) # Gray default

	# Mirror distinction for readability
	if is_mirror and is_p2_slot:
		# Darker tint for mirror match P2
		body.color = body.color.darkened(0.4)
		face_indicator.color = Color(1, 0.5, 0.5) # Reddish indicator
	else:
		face_indicator.color = Color.WHITE

	_rest_body_color = body.color
	
	# Facing handled by scale.x via parent or this node

func flash(flash_color: Color, duration: float) -> void:
	if not body:
		return
	if _flash_tween != null:
		_flash_tween.kill()
	var original := _rest_body_color
	body.color = flash_color
	_flash_tween = create_tween()
	_flash_tween.tween_property(body, "color", original, duration)
	_flash_tween.finished.connect(_on_flash_finished, CONNECT_ONE_SHOT)

func hit_stop(duration: float, recover_duration: float = 0.04) -> void:
	if duration <= 0.0:
		return

	if _hit_stop_tween != null:
		_hit_stop_tween.kill()

	var original_scale := scale
	scale = Vector2(original_scale.x * 1.05, original_scale.y * 0.97)
	_hit_stop_tween = create_tween()
	_hit_stop_tween.tween_interval(duration)
	_hit_stop_tween.tween_property(self, "scale", original_scale, recover_duration)

func _on_flash_finished() -> void:
	_flash_tween = null
