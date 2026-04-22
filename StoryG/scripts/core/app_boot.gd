extends Control

@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	status_label.text = "Preparing Story Mode..."
	await get_tree().process_frame
	await SceneRouter.go_to_entry_scene()
