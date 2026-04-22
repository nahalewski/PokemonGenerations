extends Node

signal selected_character_changed(character_id: StringName)
signal launch_payload_received(payload: Dictionary)

const DEFAULT_SAVE_SLOT := 0

var selected_character: StringName = &""
var intro_seen := false
var current_scene_path := ""
var save_slot := DEFAULT_SAVE_SLOT
var launch_params: Dictionary = {}
var pending_spawn_id: StringName = &""
var pending_location_banner := ""
var placeholder_save_slot: Dictionary = {
	"slot": DEFAULT_SAVE_SLOT,
	"has_save": false,
	"chapter": "prologue",
}


func start_new_game() -> void:
	selected_character = &""
	intro_seen = false
	current_scene_path = ""
	pending_spawn_id = &""
	pending_location_banner = ""
	save_slot = int(launch_params.get("save_slot", DEFAULT_SAVE_SLOT))


func has_continue_data() -> bool:
	return bool(placeholder_save_slot.get("has_save", false))


func set_selected_character(character_id: StringName) -> void:
	selected_character = character_id
	selected_character_changed.emit(character_id)


func mark_intro_seen() -> void:
	intro_seen = true


func set_current_scene(path: String) -> void:
	current_scene_path = path


func apply_launch_payload(payload: Dictionary) -> void:
	launch_params = payload.duplicate(true)
	if payload.has("save_slot"):
		save_slot = int(payload["save_slot"])
		placeholder_save_slot["slot"] = save_slot
	launch_payload_received.emit(launch_params)


func get_launch_param(key: StringName, default_value: Variant = null) -> Variant:
	return launch_params.get(String(key), default_value)


func set_pending_spawn(spawn_id: StringName) -> void:
	pending_spawn_id = spawn_id


func consume_pending_spawn(default_spawn: StringName = &"") -> StringName:
	var spawn := pending_spawn_id if pending_spawn_id != &"" else default_spawn
	pending_spawn_id = &""
	return spawn


func queue_location_banner(text: String) -> void:
	pending_location_banner = text


func consume_location_banner() -> String:
	var text := pending_location_banner
	pending_location_banner = ""
	return text
