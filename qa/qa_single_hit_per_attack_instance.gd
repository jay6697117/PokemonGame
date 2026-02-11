extends SceneTree

const HitResolutionServiceScript := preload("res://scripts/combat/damage/hit_resolution_service.gd")

func _init() -> void:
	var service = HitResolutionServiceScript.new()
	service.reset_attack_registry()

	var attacker_state := {
		"id": "p1",
		"position": Vector2(0, 0),
	}
	var defender_state := {
		"id": "p2",
		"position": Vector2(24, 0),
		"hp": 1000,
		"hitstun_frames": 0,
		"hurtbox": {
			"offset": Vector2(0, 0),
			"size": Vector2(40, 80),
		},
	}
	var attack_data := {
		"damage": 120,
		"hitstun_frames": 18,
		"hitbox": {
			"offset": Vector2(10, 0),
			"size": Vector2(40, 40),
		},
	}

	var first_hit: Dictionary = service.apply_attack(attacker_state, defender_state, attack_data, "atk-dup-001")
	var second_hit: Dictionary = service.apply_attack(attacker_state, defender_state, attack_data, "atk-dup-001")

	var damage_applied_count := int(first_hit.get("damage_applied_count", 0)) + int(second_hit.get("damage_applied_count", 0))
	if damage_applied_count != 1:
		printerr("Expected exactly one applied hit, got %d" % damage_applied_count)
		quit(1)
		return

	if int(defender_state.get("hp", -1)) != 880:
		printerr("Defender HP indicates repeated damage application")
		quit(1)
		return

	print("QA_SINGLE_HIT_GUARD_OK")
	print("DAMAGE_APPLIED_COUNT:%d" % damage_applied_count)
	quit(0)
