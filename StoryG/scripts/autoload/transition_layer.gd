extends CanvasLayer

@onready var fade_rect: ColorRect = ColorRect.new()


func _ready() -> void:
	layer = 100
	fade_rect.name = "FadeRect"
	fade_rect.color = Color(0.02, 0.03, 0.06, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fade_rect)


func fade_out(duration: float = 0.18) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished


func fade_in(duration: float = 0.18) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished
