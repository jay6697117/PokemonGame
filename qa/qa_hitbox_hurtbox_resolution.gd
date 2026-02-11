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

	var result: Dictionary = service.apply_attack(attacker_state, defender_state, attack_data, "atk-001")
	if not bool(result.get("hit", false)):
		printerr("Expected a hit but resolver returned miss")
		quit(1)
		return

	var hp_after := int(result.get("hp_after", -1))
	var hitstun_frames := int(result.get("hitstun_frames", -1))
	if hp_after != 880:
		printerr("Unexpected HP after hit: %d" % hp_after)
		quit(1)
		return

	if hitstun_frames != 18:
		printerr("Unexpected hitstun frames: %d" % hitstun_frames)
		quit(1)
		return

	print("QA_HITBOX_RESOLUTION_OK")
	print("HP_AFTER_HIT:%d" % hp_after)
	print("HITSTUN_FRAMES:%d" % hitstun_frames)
	quit(0)
