extends Node

signal scene_changed(path: String)

const TITLE_SCENE := "res://scenes/menus/title_screen.tscn"
const INTRO_SCENE := "res://scenes/menus/intro_screen.tscn"
const CHARACTER_SELECT_SCENE := "res://scenes/menus/character_select_screen.tscn"
const BEDROOM_SCENE := "res://scenes/world/bedroom_scene.tscn"
const LOWER_FLOOR_SCENE := "res://scenes/world/lower_floor_scene.tscn"
const TOWN_1_SCENE := "res://scenes/world/town_1_scene.tscn"

var _is_transitioning := false


func go_to_entry_scene() -> void:
	var chapter_start := String(GameSession.get_launch_param(&"chapter_start", ""))
	if chapter_start == "bedroom_debug":
		await go_to(BEDROOM_SCENE)
		return
	await go_to(TITLE_SCENE)


func go_to(path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await TransitionLayer.fade_out()
	GameSession.set_current_scene(path)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await TransitionLayer.fade_in()
	scene_changed.emit(path)
	_is_transitioning = false
