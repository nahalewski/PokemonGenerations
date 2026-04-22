extends Button

@export var character_id: StringName
@export var title_text := "Avatar"
@export var subtitle_text := "Balanced explorer"
@export var accent_color := Color(0.27, 0.55, 0.98, 1.0)
@export var portrait_texture: Texture2D

@onready var name_label: Label = %NameLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var portrait_rect: TextureRect = %PortraitRect
@onready var highlight: ColorRect = %Highlight


func _ready() -> void:
	name_label.text = title_text
	subtitle_label.text = subtitle_text
	portrait_rect.texture = portrait_texture
	portrait_rect.modulate = accent_color
	theme_type_variation = &"FlatButton"
	focus_mode = Control.FOCUS_ALL
	set_selected(false)


func set_selected(is_selected: bool) -> void:
	highlight.visible = is_selected
	scale = Vector2.ONE * (1.04 if is_selected else 1.0)
	modulate = Color(1, 1, 1, 1) if is_selected else Color(0.92, 0.94, 1.0, 0.94)
