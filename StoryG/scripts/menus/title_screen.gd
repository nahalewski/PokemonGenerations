extends Control

@onready var story_button: Button = %StoryButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var orb_a: Control = %OrbA
@onready var orb_b: Control = %OrbB
@onready var orb_c: Control = %OrbC
@onready var title_music: AudioStreamPlayer = %TitleMusic


func _ready() -> void:
	continue_button.disabled = not GameSession.has_continue_data()
	exit_button.visible = not OS.has_feature("web") and OS.get_name() != "Android"
	settings_panel.visible = false
	_configure_focus_navigation()
	story_button.grab_focus()
	_wire_actions()
	_start_background_motion()
	title_music.play()


func _wire_actions() -> void:
	story_button.pressed.connect(_on_story_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_toggle_settings)
	exit_button.pressed.connect(_exit_game)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_toggle_settings()
			get_viewport().set_input_as_handled()


func _on_story_pressed() -> void:
	GameSession.start_new_game()
	await SceneRouter.go_to(SceneRouter.INTRO_SCENE)


func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	await SceneRouter.go_to(SceneRouter.BEDROOM_SCENE)


func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	if settings_panel.visible:
		settings_button.grab_focus()
	else:
		story_button.grab_focus()


func _exit_game() -> void:
	get_tree().quit()


func _start_background_motion() -> void:
	_animate_orb(orb_a, Vector2(-80, 24), Vector2(60, -18), 6.0)
	_animate_orb(orb_b, Vector2(90, -12), Vector2(-60, 30), 7.5)
	_animate_orb(orb_c, Vector2(-36, -40), Vector2(40, 60), 8.2)


func _animate_orb(node: Control, from_offset: Vector2, to_offset: Vector2, duration: float) -> void:
	node.position += from_offset
	var tween := create_tween().set_loops()
	tween.tween_property(node, "position", node.position + to_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", node.position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _configure_focus_navigation() -> void:
	if not exit_button.visible:
		settings_button.focus_neighbor_bottom = NodePath("../StoryButton")
		exit_button.focus_mode = Control.FOCUS_NONE
