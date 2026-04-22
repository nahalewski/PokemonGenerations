extends Control

@onready var save_details = $Panel/VBoxContainer/SaveDetails
@onready var continue_button = $Panel/VBoxContainer/HBoxContainer/ContinueButton

func _ready():
	if Global.load_game():
		# Format and display save information
		var info_text = "PLAYER: " + Global.player_name + "\n"
		info_text += "GENDER: " + Global.selected_gender.to_upper() + "\n"
		info_text += "LOCATION: " + Global.current_location
		save_details.text = info_text
	else:
		save_details.text = "No save file found."
		continue_button.disabled = true
	
	continue_button.grab_focus()

func _on_continue_button_pressed():
	# Proceed to the game world with loaded data
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_cancel_button_pressed():
	# Go back to title screen
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_delete_button_pressed():
	# Implementation of save deletion
	# This could be a confirmation dialog in a more complex setup
	var dir = DirAccess.open("user://")
	if dir.file_exists("save_data.json"):
		dir.remove("save_data.json")
		# Reset global data
		Global.player_name = "Player"
		Global.selected_gender = ""
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
