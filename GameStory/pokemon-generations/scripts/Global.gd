extends Node

# Player Data
var selected_gender: String = "" # "boy" or "girl"
var player_name: String = "Player"
var current_location: String = "Pallet Town"

# Settings
var bgm_volume: float = 0.8
var sfx_volume: float = 0.8
var text_speed: float = 0.05 # 0.05 is standard, lower is faster
var resolution_index: int = 1 # Default 1080p

const SAVE_PATH = "user://save_data.json"
const SETTINGS_PATH = "user://settings.json"

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _ready():
	load_settings()

func save_game():
	var save_dict = {
		"selected_gender": selected_gender,
		"player_name": player_name,
		"current_location": current_location
	}
	var json_string = JSON.stringify(save_dict)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_string)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data = json.get_data()
		selected_gender = data.get("selected_gender", "")
		player_name = data.get("player_name", "Player")
		current_location = data.get("current_location", "Pallet Town")
		return true
	return false

func save_settings():
	var settings_dict = {
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"text_speed": text_speed,
		"resolution_index": resolution_index
	}
	var json_string = JSON.stringify(settings_dict)
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_string(json_string)

func load_settings():
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data = json.get_data()
		bgm_volume = data.get("bgm_volume", 0.8)
		sfx_volume = data.get("sfx_volume", 0.8)
		text_speed = data.get("text_speed", 0.05)
		resolution_index = data.get("resolution_index", 1)
		apply_settings()

func apply_settings():
	# Apply Audio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(bgm_volume))
	
	# Apply Resolution (Desktop only)
	if OS.get_name() in ["Windows", "macOS", "Linux"]:
		var res = RESOLUTIONS[resolution_index]
		var window = get_window()
		
		# High-level Window properties are often safer than direct DisplayServer calls in subwindow modes
		window.mode = Window.MODE_WINDOWED
		window.size = res
		
		# Center window manually
		var screen_id = window.current_screen
		var screen_size = DisplayServer.screen_get_size(screen_id)
		window.position = (screen_size / 2) - (res / 2)
