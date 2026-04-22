extends Control

@onready var bgm_slider = $Panel/VBoxContainer/AudioSettings/BGMSlider
@onready var sfx_slider = $Panel/VBoxContainer/AudioSettings/SFXSlider
@onready var text_speed_option = $Panel/VBoxContainer/GameSettings/TextSpeedOption
@onready var resolution_option = $Panel/VBoxContainer/DisplaySettings/ResolutionOption

func _ready():
	# Initialize Audio sliders
	bgm_slider.value = Global.bgm_volume
	sfx_slider.value = Global.sfx_volume
	
	# Initialize Text Speed
	if Global.text_speed <= 0.02: text_speed_option.selected = 2
	elif Global.text_speed <= 0.05: text_speed_option.selected = 1
	else: text_speed_option.selected = 0
	
	# Initialize Resolution
	_setup_resolution_options()
	resolution_option.selected = Global.resolution_index
	
	# Set focus for gamepad navigation
	bgm_slider.grab_focus()

func _setup_resolution_options():
	resolution_option.clear()
	for res in Global.RESOLUTIONS:
		resolution_option.add_item(str(res.x) + "x" + str(res.y))

func _on_resolution_option_item_selected(index):
	Global.resolution_index = index
	Global.apply_settings()

func _on_bgm_slider_value_changed(value):
	Global.bgm_volume = value
	Global.apply_settings()

func _on_sfx_slider_value_changed(value):
	Global.sfx_volume = value

func _on_back_button_pressed():
	Global.save_settings()
	# Transition back to Title
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_text_speed_option_item_selected(index):
	match index:
		0: Global.text_speed = 0.08 # Slow
		1: Global.text_speed = 0.05 # Normal
		2: Global.text_speed = 0.02 # Fast
