extends RefCounted
class_name FighterStateMachine

enum FighterState {
	IDLE,
	MOVE,
	JUMP,
	CROUCH,
	ATTACK,
	HITSTUN,
	KO,
}

const ALLOWED_TRANSITIONS := {
	FighterState.IDLE: [FighterState.MOVE, FighterState.JUMP, FighterState.CROUCH, FighterState.ATTACK, FighterState.HITSTUN, FighterState.KO],
	FighterState.MOVE: [FighterState.IDLE, FighterState.JUMP, FighterState.CROUCH, FighterState.ATTACK, FighterState.HITSTUN, FighterState.KO],
	FighterState.JUMP: [FighterState.IDLE, FighterState.ATTACK, FighterState.HITSTUN, FighterState.KO],
	FighterState.CROUCH: [FighterState.IDLE, FighterState.ATTACK, FighterState.HITSTUN, FighterState.KO],
	FighterState.ATTACK: [FighterState.IDLE, FighterState.HITSTUN, FighterState.KO],
	FighterState.HITSTUN: [FighterState.IDLE, FighterState.KO],
	FighterState.KO: [FighterState.IDLE],
}

var current_state: FighterState = FighterState.IDLE
var transition_log: PackedStringArray = []
var last_guard_message := ""

func reset() -> void:
	current_state = FighterState.IDLE
	transition_log.clear()
	last_guard_message = ""

func force_state(target_state: FighterState) -> void:
	current_state = target_state

func transition_to(target_state: FighterState) -> bool:
	if current_state == target_state:
		return true

	var allowed_targets: Array = ALLOWED_TRANSITIONS.get(current_state, [])
	if not allowed_targets.has(target_state):
		last_guard_message = "BLOCKED: %s->%s" % [get_state_name(current_state), get_state_name(target_state)]
		transition_log.append(last_guard_message)
		return false

	transition_log.append("%s->%s" % [get_state_name(current_state), get_state_name(target_state)])
	current_state = target_state
	return true

func get_state_name(state: FighterState) -> String:
	match state:
		FighterState.IDLE:
			return "IDLE"
		FighterState.MOVE:
			return "MOVE"
		FighterState.JUMP:
			return "JUMP"
		FighterState.CROUCH:
			return "CROUCH"
		FighterState.ATTACK:
			return "ATTACK"
		FighterState.HITSTUN:
			return "HITSTUN"
		FighterState.KO:
			return "KO"
		_:
			return "UNKNOWN"
