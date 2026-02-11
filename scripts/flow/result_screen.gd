extends Node

func request_rematch(flow_controller: RefCounted) -> Dictionary:
	if flow_controller == null:
		return {
			"ok": false,
			"error_code": "ERR_NO_FLOW_CONTROLLER",
		}

	if not flow_controller.has_method("request_rematch"):
		return {
			"ok": false,
			"error_code": "ERR_MISSING_METHOD",
		}

	return flow_controller.call("request_rematch")
