extends Control

@onready var logo = $Logo
@onready var prompt = $PressStart
@onready var menu = $MenuOptions
@onready var continue_button = $MenuOptions/ContinueButton
@onready var new_game_button = $MenuOptions/NewGameButton
@onready var settings_button = $MenuOptions/SettingsButton
@onready var settings_cog = $SettingsCog

var menu_open = false

func _ready():
	# 1. Pulserende blink-effekt for "Press Start"
	var tween_blink = create_tween().set_loops()
	tween_blink.tween_property(prompt, "modulate:a", 0.0, 0.8)
	tween_blink.tween_property(prompt, "modulate:a", 1.0, 0.8)
	
	# 2. Vedvarende sveve-animasjon for logoen
	var tween_logo = create_tween().set_loops()
	tween_logo.tween_property(logo, "position:y", logo.position.y + 15, 2.0).set_trans(Tween.TRANS_SINE)
	tween_logo.tween_property(logo, "position:y", logo.position.y, 2.0).set_trans(Tween.TRANS_SINE)
	
	# 3. Subtle rotation for the Cog
	var tween_cog = create_tween().set_loops()
	tween_cog.tween_property(settings_cog, "rotation_degrees", 360, 10.0).as_relative()
	
	# Detect save file
	if not FileAccess.file_exists(Global.SAVE_PATH):
		continue_button.visible = false
	
	# Connect signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	settings_cog.pressed.connect(_on_settings_pressed)

func _input(event):
	if not menu_open and (event.is_action_pressed("ui_accept") or event is InputEventMouseButton):
		show_menu()

func show_menu():
	menu_open = true
	prompt.visible = false
	menu.visible = true
	
	# Focus magic for gamepad
	if continue_button.visible:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

func _on_new_game_pressed():
	# Reset Global and start from Intro
	Global.player_name = "Player"
	Global.selected_gender = ""
	get_tree().change_scene_to_file("res://scenes/intro_screen.tscn")

func _on_continue_pressed():
	# Go to Continue screen to see save details
	get_tree().change_scene_to_file("res://scenes/continue_screen.tscn")

func _on_settings_pressed():
	# Go to Settings
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
