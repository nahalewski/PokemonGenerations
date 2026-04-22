extends CharacterBody2D

signal movement_state_changed(state_name: StringName)

@export var walk_speed := 90.0
@export var acceleration := 12.0
@export var male_texture: Texture2D = preload("res://assets/imported/characters/player_m_walk.png")
@export var female_texture: Texture2D = preload("res://assets/imported/characters/player_f_walk.png")

@onready var sprite: Sprite2D = %Sprite2D

var _input_enabled := true
var _movement_state: StringName = &"idle"
var _frame_clock := 0.0
var _last_direction := Vector2.DOWN


func _ready() -> void:
	sprite.texture = male_texture if GameSession.selected_character != &"player_f" else female_texture


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if _input_enabled:
		input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var desired_velocity := input_vector * walk_speed
	velocity = velocity.move_toward(desired_velocity, acceleration * walk_speed * delta)

	if input_vector.length_squared() > 0.001:
		_last_direction = input_vector.normalized()
		_set_movement_state(&"walk")
	else:
		_set_movement_state(&"idle")

	move_and_slide()
	_update_sprite(delta, input_vector)


func set_input_enabled(is_enabled: bool) -> void:
	_input_enabled = is_enabled
	if not is_enabled:
		velocity = Vector2.ZERO


func _update_sprite(delta: float, input_vector: Vector2) -> void:
	var row := _direction_to_row(_last_direction)
	if input_vector.length_squared() > 0.001:
		_frame_clock += delta * 10.0
		sprite.frame = int(_frame_clock) % 4
	else:
		_frame_clock = 1.0
		sprite.frame = 1
	sprite.frame_coords = Vector2i(sprite.frame, row)


func _direction_to_row(direction: Vector2) -> int:
	if absf(direction.x) > absf(direction.y):
		return 1 if direction.x < 0.0 else 2
	return 3 if direction.y < 0.0 else 0


func _set_movement_state(new_state: StringName) -> void:
	if new_state == _movement_state:
		return
	_movement_state = new_state
	movement_state_changed.emit(new_state)
