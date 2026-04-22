extends Node2D

const TILE_SIZE := 32

@onready var player: CharacterBody2D = %PlayerCharacter
@onready var wake_label: Label = %WakeLabel
@onready var floor_layer: Node2D = %FloorLayer
@onready var wall_layer: Node2D = %WallLayer
@onready var furniture_layer: Node2D = %FurnitureLayer
@onready var collision_root: Node2D = %CollisionRoot
@onready var grid_root: Node2D = %GridRoot
@onready var spawn_bedroom: Marker2D = %SpawnBedroom
@onready var spawn_town_exit: Marker2D = %SpawnTownExit

var _transition_locked := false


func _ready() -> void:
	_build_layout()
	_place_player()
	wake_label.text = "Lower Floor Test Area"
	wake_label.modulate.a = 0.0


func _physics_process(_delta: float) -> void:
	if _transition_locked:
		return
	var tile_position := Vector2i(floori(player.global_position.x / TILE_SIZE), floori(player.global_position.y / TILE_SIZE))
	if tile_position == Vector2i(9, 6) or tile_position == Vector2i(10, 6):
		_transition_locked = true
		GameSession.set_pending_spawn(&"from_lower_floor")
		GameSession.queue_location_banner("Town 1")
		SceneRouter.go_to(SceneRouter.TOWN_1_SCENE)


func _build_layout() -> void:
	_clear_node(floor_layer)
	_clear_node(wall_layer)
	_clear_node(furniture_layer)
	_clear_collision_root()
	_fill_floor(Rect2i(0, 0, 12, 9), Color(0.74, 0.70, 0.58))
	_fill_wall_band(Rect2i(0, 0, 12, 1), Color(0.61, 0.70, 0.76))
	_fill_wall_band(Rect2i(0, 8, 12, 1), Color(0.52, 0.61, 0.68))
	_fill_wall_band(Rect2i(0, 1, 1, 7), Color(0.64, 0.72, 0.78))
	_fill_wall_band(Rect2i(11, 1, 1, 7), Color(0.64, 0.72, 0.78))
	_fill_furniture(Rect2i(2, 2, 2, 2), Color(0.55, 0.40, 0.27), "STAIRS")
	_fill_furniture(Rect2i(7, 2, 2, 2), Color(0.66, 0.50, 0.30), "EXIT")
	_build_grid_overlay(Vector2i(12, 9))
	_add_collision(Rect2(0, 0, 12, 1))
	_add_collision(Rect2(0, 8, 12, 1))
	_add_collision(Rect2(0, 1, 1, 7))
	_add_collision(Rect2(11, 1, 1, 7))
	_add_collision(Rect2(2, 2, 2, 2))


func _place_player() -> void:
	var spawn_id := GameSession.consume_pending_spawn(&"from_bedroom")
	player.global_position = spawn_town_exit.global_position if spawn_id == &"from_town" else spawn_bedroom.global_position


func _fill_floor(tile_rect: Rect2i, color: Color) -> void:
	for y in range(tile_rect.position.y, tile_rect.end.y):
		for x in range(tile_rect.position.x, tile_rect.end.x):
			var cell := ColorRect.new()
			cell.color = color if ((x + y) % 2 == 0) else color.darkened(0.04)
			cell.position = Vector2(x, y) * TILE_SIZE
			cell.size = Vector2.one() * TILE_SIZE
			floor_layer.add_child(cell)


func _fill_wall_band(tile_rect: Rect2i, color: Color) -> void:
	var wall := ColorRect.new()
	wall.color = color
	wall.position = tile_rect.position * TILE_SIZE
	wall.size = tile_rect.size * TILE_SIZE
	wall_layer.add_child(wall)


func _fill_furniture(tile_rect: Rect2i, color: Color, label_text: String) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = tile_rect.position * TILE_SIZE
	rect.size = tile_rect.size * TILE_SIZE
	furniture_layer.add_child(rect)
	var label := Label.new()
	label.text = label_text
	label.position = rect.position + Vector2(8, 12)
	label.add_theme_font_size_override("font_size", 14)
	furniture_layer.add_child(label)


func _build_grid_overlay(room_size: Vector2i) -> void:
	for child in grid_root.get_children():
		child.queue_free()
	var width := room_size.x * TILE_SIZE
	var height := room_size.y * TILE_SIZE
	for x in range(room_size.x + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.08)
		line.position = Vector2(x * TILE_SIZE, 0)
		line.size = Vector2(1, height)
		grid_root.add_child(line)
	for y in range(room_size.y + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.08)
		line.position = Vector2(0, y * TILE_SIZE)
		line.size = Vector2(width, 1)
		grid_root.add_child(line)


func _clear_collision_root() -> void:
	_clear_node(collision_root)


func _clear_node(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


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
