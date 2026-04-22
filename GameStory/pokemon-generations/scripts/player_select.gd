extends Control

@onready var boy_button = %BoyButton
@onready var girl_button = %GirlButton
@onready var confirm_sound = null # Placeholder for later

func _ready():
	# For gamepad/keyboard support, we MUST focus one button first
	boy_button.grab_focus()

func _on_boy_button_pressed():
	select_character("boy")

func _on_girl_button_pressed():
	select_character("girl")

func select_character(gender: String):
	Global.selected_gender = gender
	print("Character selected: ", gender)
	advance_to_world()

func advance_to_world():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

# Handling selection via keyboard/gamepad focus
func _input(event):
	if event.is_action_pressed("ui_accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused == boy_button:
			select_character("boy")
		elif focused == girl_button:
			select_character("girl")
