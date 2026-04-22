extends Node

const DEFAULT_DEADZONE := 0.35

func _ready() -> void:
	_register_defaults()
	_log_connected_gamepads()


func _register_defaults() -> void:
	_ensure_action("ui_accept", [_key(KEY_ENTER), _key(KEY_SPACE), _joy_button(JOY_BUTTON_A)])
	_ensure_action("ui_cancel", [_key(KEY_ESCAPE), _key(KEY_BACKSPACE), _joy_button(JOY_BUTTON_B), _joy_button(JOY_BUTTON_BACK)])
	_ensure_action("ui_left", [_key(KEY_LEFT), _key(KEY_A), _joy_axis(JOY_AXIS_LEFT_X, -1.0), _joy_button(JOY_BUTTON_DPAD_LEFT)])
	_ensure_action("ui_right", [_key(KEY_RIGHT), _key(KEY_D), _joy_axis(JOY_AXIS_LEFT_X, 1.0), _joy_button(JOY_BUTTON_DPAD_RIGHT)])
	_ensure_action("ui_up", [_key(KEY_UP), _key(KEY_W), _joy_axis(JOY_AXIS_LEFT_Y, -1.0), _joy_button(JOY_BUTTON_DPAD_UP)])
	_ensure_action("ui_down", [_key(KEY_DOWN), _key(KEY_S), _joy_axis(JOY_AXIS_LEFT_Y, 1.0), _joy_button(JOY_BUTTON_DPAD_DOWN)])
	_ensure_action("move_left", [_key(KEY_A), _key(KEY_LEFT), _joy_axis(JOY_AXIS_LEFT_X, -1.0), _joy_button(JOY_BUTTON_DPAD_LEFT)])
	_ensure_action("move_right", [_key(KEY_D), _key(KEY_RIGHT), _joy_axis(JOY_AXIS_LEFT_X, 1.0), _joy_button(JOY_BUTTON_DPAD_RIGHT)])
	_ensure_action("move_forward", [_key(KEY_W), _key(KEY_UP), _joy_axis(JOY_AXIS_LEFT_Y, -1.0), _joy_button(JOY_BUTTON_DPAD_UP)])
	_ensure_action("move_back", [_key(KEY_S), _key(KEY_DOWN), _joy_axis(JOY_AXIS_LEFT_Y, 1.0), _joy_button(JOY_BUTTON_DPAD_DOWN)])
	_ensure_action("interact", [_key(KEY_E), _key(KEY_ENTER), _joy_button(JOY_BUTTON_A)])
	_ensure_action("pause", [_key(KEY_ESCAPE), _key(KEY_P), _joy_button(JOY_BUTTON_START), _joy_button(JOY_BUTTON_BACK)])
	_ensure_action("advance_dialogue", [_key(KEY_ENTER), _key(KEY_SPACE), _joy_button(JOY_BUTTON_A)])
	_ensure_action("skip_intro", [_key(KEY_ESCAPE), _key(KEY_X), _joy_button(JOY_BUTTON_Y), _joy_button(JOY_BUTTON_RIGHT_SHOULDER)])


func _ensure_action(action_name: StringName, events: Array[InputEvent]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, DEFAULT_DEADZONE)
	for event in events:
		if not InputMap.action_has_event(action_name, event):
			InputMap.action_add_event(action_name, event)

func _key(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	return event


func _joy_button(button_index: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	return event


func _joy_axis(axis: JoyAxis, axis_value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	return event


func _log_connected_gamepads() -> void:
	for device_id in Input.get_connected_joypads():
		print("Gamepad detected: id=%s name=%s" % [device_id, Input.get_joy_name(device_id)])
