extends Control

signal sequence_finished

@export var lines: Array[Dictionary] = []

@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var continue_label: Label = %ContinueLabel
@onready var skip_button: Button = %SkipButton

var _current_index := 0


func _ready() -> void:
	skip_button.pressed.connect(skip)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_view()


func set_lines(new_lines: Array[Dictionary]) -> void:
	lines = new_lines
	_current_index = 0
	_update_view()


func advance() -> void:
	if _current_index >= lines.size() - 1:
		sequence_finished.emit()
		return
	_current_index += 1
	_update_view()


func skip() -> void:
	sequence_finished.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue") or event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("skip_intro") or event.is_action_pressed("ui_cancel"):
		skip()
		get_viewport().set_input_as_handled()


func _update_view() -> void:
	if lines.is_empty():
		speaker_label.text = ""
		body_label.text = ""
		return
	var line: Dictionary = lines[_current_index]
	speaker_label.text = String(line.get("speaker", "Narrator"))
	body_label.text = "[center]%s[/center]" % String(line.get("text", ""))
	continue_label.text = "Tap / Enter / A to continue  |  Esc / Y to skip"
