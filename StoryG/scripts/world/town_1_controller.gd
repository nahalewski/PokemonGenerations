extends Node2D

const TILE_SIZE := 32

@onready var player: CharacterBody2D = %PlayerCharacter
@onready var location_banner: PanelContainer = %LocationBanner
@onready var location_label: Label = %LocationLabel
@onready var note_label: Label = %NoteLabel
@onready var collision_root: Node2D = %CollisionRoot
@onready var grid_root: Node2D = %GridRoot
@onready var spawn_from_house: Marker2D = %SpawnFromHouse

var _transition_locked := false


func _ready() -> void:
	_build_map()
	player.global_position = spawn_from_house.global_position
	note_label.text = "Placeholder ground color only for Kishi/controller testing. Replace with final town tiles later."
	_show_location_banner()


func _physics_process(_delta: float) -> void:
	if _transition_locked:
		return
	var tile_position := Vector2i(floori(player.global_position.x / TILE_SIZE), floori(player.global_position.y / TILE_SIZE))
	if tile_position == Vector2i(8, 2) or tile_position == Vector2i(9, 2):
		_transition_locked = true
		GameSession.set_pending_spawn(&"from_town")
		SceneRouter.go_to(SceneRouter.LOWER_FLOOR_SCENE)


func _build_map() -> void:
	_clear_node(collision_root)
	_clear_node(grid_root)
	_build_grid_overlay(Vector2i(20, 14))
	_add_collision(Rect2(0, 0, 20, 1))
	_add_collision(Rect2(0, 13, 20, 1))
	_add_collision(Rect2(0, 1, 1, 12))
	_add_collision(Rect2(19, 1, 1, 12))
	_add_collision(Rect2(7, 0, 5, 3))


func _show_location_banner() -> void:
	var banner_text := GameSession.consume_location_banner()
	if banner_text.is_empty():
		location_banner.visible = false
		return
	location_label.text = banner_text
	location_banner.visible = true
	location_banner.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(location_banner, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.4)
	tween.tween_property(location_banner, "modulate:a", 0.0, 0.35)
	await tween.finished
	location_banner.visible = false


func _build_grid_overlay(room_size: Vector2i) -> void:
	var width := room_size.x * TILE_SIZE
	var height := room_size.y * TILE_SIZE
	for x in range(room_size.x + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.06)
		line.position = Vector2(x * TILE_SIZE, 0)
		line.size = Vector2(1, height)
		grid_root.add_child(line)
	for y in range(room_size.y + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.06)
		line.position = Vector2(0, y * TILE_SIZE)
		line.size = Vector2(width, 1)
		grid_root.add_child(line)


func _add_collision(tile_rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = tile_rect.position * TILE_SIZE
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = tile_rect.size * TILE_SIZE
	shape.shape = rect
	shape.position = rect.size * 0.5
	body.add_child(shape)
	collision_root.add_child(body)


func _clear_node(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
