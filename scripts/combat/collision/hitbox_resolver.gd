extends RefCounted
class_name HitboxResolver

func resolve_hit(
	attacker_state: Dictionary,
	defender_state: Dictionary,
	attack_data: Dictionary,
	attack_instance_id: String,
	hit_registry: Dictionary
) -> Dictionary:
	var result := {
		"hit": false,
		"damage_applied_count": 0,
		"hp_after": int(defender_state.get("hp", 0)),
		"hitstun_frames": int(defender_state.get("hitstun_frames", 0)),
	}

	var attacker_position := Vector2(attacker_state.get("position", Vector2.ZERO))
	var defender_position := Vector2(defender_state.get("position", Vector2.ZERO))

	var attack_hitbox: Dictionary = attack_data.get("hitbox", {})
	var defender_hurtbox: Dictionary = defender_state.get("hurtbox", {})

	var attack_rect := _build_rect(attacker_position, attack_hitbox)
	var hurt_rect := _build_rect(defender_position, defender_hurtbox)

	if not _rects_overlap(attack_rect, hurt_rect):
		return result

	var defender_id := str(defender_state.get("id", "defender"))
	var registry_key := "%s:%s" % [attack_instance_id, defender_id]
	if hit_registry.has(registry_key):
		return result

	hit_registry[registry_key] = true

	var damage: int = maxi(int(attack_data.get("damage", 0)), 0)
	var hitstun: int = maxi(int(attack_data.get("hitstun_frames", 0)), 0)
	var hp_before := int(defender_state.get("hp", 0))
	var hp_after: int = maxi(hp_before - damage, 0)

	defender_state["hp"] = hp_after
	defender_state["hitstun_frames"] = hitstun

	result["hit"] = true
	result["damage_applied_count"] = 1
	result["hp_after"] = hp_after
	result["hitstun_frames"] = hitstun
	return result

func _build_rect(base_position: Vector2, shape_data: Dictionary) -> Rect2:
	var offset := Vector2(shape_data.get("offset", Vector2.ZERO))
	var size := Vector2(shape_data.get("size", Vector2.ZERO)).abs()
	return Rect2(base_position + offset, size)

func _rects_overlap(a: Rect2, b: Rect2) -> bool:
	return a.intersects(b)
