extends Node2D

const TILE_ATLAS_SIZE := Vector2i(16, 16)
const TILE_WORLD_SCALE := Vector2(2, 2)
const TILE_SIZE := 32
const TILE_SOURCE_ID := 0

const FLOOR_TILE := Vector2i(0, 66)
const FLOOR_ALT_TILE := Vector2i(1, 66)
const WALL_TILE := Vector2i(3, 12)
const WALL_ALT_TILE := Vector2i(4, 12)
const BED_TILE := Vector2i(6, 95)
const DESK_TILE := Vector2i(0, 146)
const DOOR_TILE := Vector2i(5, 138)
const WINDOW_TILE := Vector2i(7, 104)
const POSTER_TILE := Vector2i(1, 14)

@onready var player: CharacterBody2D = %PlayerCharacter
@onready var wake_label: Label = %WakeLabel
@onready var selected_name_label: Label = %SelectedNameLabel
@onready var floor_layer: TileMapLayer = %FloorLayer
@onready var wall_layer: TileMapLayer = %WallLayer
@onready var furniture_layer: TileMapLayer = %FurnitureLayer
@onready var collision_root: Node2D = %CollisionRoot
@onready var grid_root: Node2D = %GridRoot
@onready var spawn_default: Marker2D = %SpawnDefault

var _interior_tiles: Texture2D = preload("res://assets/imported/tilesets/4g tileset_interieur.png")
var _transition_locked := false


func _ready() -> void:
	var character_name := "Trainer"
	if GameSession.selected_character != &"":
		character_name = String(GameSession.selected_character).capitalize()
	selected_name_label.text = "Selected avatar: %s" % character_name
	_build_room()
	player.global_position = spawn_default.global_position
	player.set_input_enabled(false)
	_begin_wake_sequence()


func _physics_process(_delta: float) -> void:
	if _transition_locked:
		return
	var tile_position := Vector2i(floori(player.global_position.x / TILE_SIZE), floori(player.global_position.y / TILE_SIZE))
	if tile_position == Vector2i(10, 3) or tile_position == Vector2i(10, 4):
		_transition_locked = true
		GameSession.set_pending_spawn(&"from_bedroom")
		SceneRouter.go_to(SceneRouter.LOWER_FLOOR_SCENE)


func _begin_wake_sequence() -> void:
	wake_label.text = "A new chapter begins..."
	wake_label.visible = true
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(wake_label, "modulate:a", 0.0, 0.8)
	await tween.finished
	wake_label.visible = false
	player.set_input_enabled(true)


func _build_room() -> void:
	var tile_set := _build_tileset()
	for layer in [floor_layer, wall_layer, furniture_layer]:
		layer.tile_set = tile_set
		layer.scale = TILE_WORLD_SCALE
		layer.clear()

	_fill_floor(Rect2i(0, 0, 12, 9))
	_fill_walls()
	_fill_furniture()
	_build_grid_overlay(Vector2i(12, 9))
	_clear_collision_root()
	_add_collision(Rect2(0, 0, 12, 1))
	_add_collision(Rect2(0, 8, 12, 1))
	_add_collision(Rect2(0, 1, 1, 7))
	_add_collision(Rect2(11, 1, 1, 7))
	_add_collision(Rect2(7, 1, 3, 2))
	_add_collision(Rect2(2, 1, 3, 2))
	_add_collision(Rect2(10, 3, 1, 2))


func _build_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_ATLAS_SIZE
	var atlas := TileSetAtlasSource.new()
	atlas.texture = _interior_tiles
	atlas.texture_region_size = TILE_ATLAS_SIZE
	tile_set.add_source(atlas, TILE_SOURCE_ID)
	for atlas_coords in [
		FLOOR_TILE,
		FLOOR_ALT_TILE,
		WALL_TILE,
		WALL_ALT_TILE,
		BED_TILE,
		DESK_TILE,
		DOOR_TILE,
		WINDOW_TILE,
		POSTER_TILE,
	]:
		if not atlas.has_tile(atlas_coords):
			atlas.create_tile(atlas_coords)
	return tile_set


func _fill_floor(tile_rect: Rect2i) -> void:
	for y in range(tile_rect.position.y, tile_rect.end.y):
		for x in range(tile_rect.position.x, tile_rect.end.x):
			var atlas_coords := FLOOR_TILE if ((x + y) % 2 == 0) else FLOOR_ALT_TILE
			floor_layer.set_cell(Vector2i(x, y), TILE_SOURCE_ID, atlas_coords)


func _fill_walls() -> void:
	for x in range(12):
		wall_layer.set_cell(Vector2i(x, 0), TILE_SOURCE_ID, WALL_TILE if x % 2 == 0 else WALL_ALT_TILE)
		wall_layer.set_cell(Vector2i(x, 8), TILE_SOURCE_ID, WALL_TILE if x % 2 == 0 else WALL_ALT_TILE)
	for y in range(1, 8):
		wall_layer.set_cell(Vector2i(0, y), TILE_SOURCE_ID, WALL_ALT_TILE if y % 2 == 0 else WALL_TILE)
		wall_layer.set_cell(Vector2i(11, y), TILE_SOURCE_ID, WALL_ALT_TILE if y % 2 == 0 else WALL_TILE)


func _fill_furniture() -> void:
	for tile in [Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1), Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2)]:
		furniture_layer.set_cell(tile, TILE_SOURCE_ID, BED_TILE)
	for tile in [Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2)]:
		furniture_layer.set_cell(tile, TILE_SOURCE_ID, DESK_TILE)
	for tile in [Vector2i(10, 3), Vector2i(10, 4)]:
		furniture_layer.set_cell(tile, TILE_SOURCE_ID, DOOR_TILE)
	for tile in [Vector2i(6, 0), Vector2i(7, 0)]:
		furniture_layer.set_cell(tile, TILE_SOURCE_ID, WINDOW_TILE)
	for tile in [Vector2i(1, 5), Vector2i(1, 6)]:
		furniture_layer.set_cell(tile, TILE_SOURCE_ID, POSTER_TILE)


func _build_grid_overlay(room_size: Vector2i) -> void:
	for child in grid_root.get_children():
		child.queue_free()
	var width := room_size.x * TILE_SIZE
	var height := room_size.y * TILE_SIZE
	for x in range(room_size.x + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.12)
		line.position = Vector2(x * TILE_SIZE, 0)
		line.size = Vector2(1, height)
		grid_root.add_child(line)
	for y in range(room_size.y + 1):
		var line := ColorRect.new()
		line.color = Color(1, 1, 1, 0.12)
		line.position = Vector2(0, y * TILE_SIZE)
		line.size = Vector2(width, 1)
		grid_root.add_child(line)


func _clear_collision_root() -> void:
	for child in collision_root.get_children():
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
