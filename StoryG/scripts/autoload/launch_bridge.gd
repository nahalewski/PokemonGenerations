extends Node

func _ready() -> void:
	var payload := _read_launch_payload()
	if not payload.is_empty():
		GameSession.apply_launch_payload(payload)


func apply_external_payload(payload: Dictionary) -> void:
	GameSession.apply_launch_payload(payload)


func _read_launch_payload() -> Dictionary:
	var payload := _parse_command_line_args()
	if OS.has_feature("web"):
		payload.merge(_parse_web_query(), true)
	return payload


func _parse_command_line_args() -> Dictionary:
	var payload: Dictionary = {}
	for argument in OS.get_cmdline_user_args():
		if not argument.begins_with("--"):
			continue
		var parts := argument.trim_prefix("--").split("=", false, 1)
		if parts.size() == 2:
			payload[parts[0]] = parts[1]
	return payload


func _parse_web_query() -> Dictionary:
	var payload: Dictionary = {}
	var query_string: Variant = JavaScriptBridge.eval("window.location.search", true)
	if query_string == null:
		return payload
	var query := String(query_string).trim_prefix("?")
	if query.is_empty():
		return payload
	for pair in query.split("&", false):
		var parts := pair.split("=", false, 1)
		if parts.size() == 2:
			payload[parts[0].uri_decode()] = parts[1].uri_decode()
	return payload
