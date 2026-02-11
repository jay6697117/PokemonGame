extends RefCounted
class_name HitResolutionService

const HitboxResolverScript := preload("res://scripts/combat/collision/hitbox_resolver.gd")

var _resolver = HitboxResolverScript.new()
var _hit_registry: Dictionary = {}

func reset_attack_registry() -> void:
	_hit_registry.clear()

func apply_attack(
	attacker_state: Dictionary,
	defender_state: Dictionary,
	attack_data: Dictionary,
	attack_instance_id: String
) -> Dictionary:
	return _resolver.resolve_hit(
		attacker_state,
		defender_state,
		attack_data,
		attack_instance_id,
		_hit_registry
	)
